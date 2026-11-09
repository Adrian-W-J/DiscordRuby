require 'json'
require 'net/http'
require 'uri'
require 'openssl'

module DiscordRuby
  class APIClient
    def initialize(token:, default_headers: {})
      @token = token
      @headers = default_headers.merge(
        'Authorization' => "Bot #{@token}",
        'Content-Type' => 'application/json'
      )
    end

    def request(method, path, params: nil, body: nil, headers: {}, files: {})
      uri = URI("#{DiscordRuby::API_BASE}#{path}")
      uri.query = URI.encode_www_form(params) if params && !params.empty?

      if ENV['DEBUG']
        route = path.sub(%r{\A(/(?:webhooks|interactions)/[^/]+/)[^/]+}, '\1[REDACTED]')
        puts "[DEBUG] API Request: #{method.upcase} #{route}"
      end

      request_class = case method.to_s.downcase
                      when 'get' then Net::HTTP::Get
                      when 'post' then Net::HTTP::Post
                      when 'patch' then Net::HTTP::Patch
                      when 'put' then Net::HTTP::Put
                      when 'delete' then Net::HTTP::Delete
                      else
                        raise ArgumentError, "Unsupported HTTP method: #{method}"
                      end

      request = request_class.new(uri)
      request.initialize_http_header(@headers.merge(headers))
      if files.empty?
        request.body = JSON.generate(body) if body
      else
        parts = [['payload_json', JSON.generate(body), {content_type: 'application/json'}]]
        files.each_with_index do |(filename, bytes), index|
          unless filename.is_a?(String) && !filename.empty? && !filename.match?(/[\r\n\/\\]/)
            raise ArgumentError, 'upload filenames must be nonempty basenames'
          end
          parts << ["files[#{index}]", bytes, {filename: filename, content_type: 'application/octet-stream'}]
        end
        request.set_form(parts, 'multipart/form-data')
      end

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end

      parse_response(response)
    end

    def fetch_my_user
      request(:get, '/users/@me')
    end

    def fetch_user(user_id)
      data = request(:get, "/users/#{user_id}")
      User.new(self, data)
    end

    def modify_current_user(username: nil, avatar: nil)
      body = {}
      body[:username] = username if username
      body[:avatar] = avatar if avatar
      request(:patch, '/users/@me', body: body)
    end

    def fetch_channel(channel_id)
      data = request(:get, "/channels/#{channel_id}")
      Channel.new(self, data)
    end

    def fetch_channel_messages(channel_id, limit: 50, before: nil, after: nil, around: nil)
      params = {limit: limit}
      params[:before] = before if before
      params[:after] = after if after
      params[:around] = around if around
      request(:get, "/channels/#{channel_id}/messages", params: params)
    end

    def send_message(channel_id, content = nil, files: {}, **options)
      body = options.slice(:content, :tts, :embeds, :components, :flags, :poll, :message_reference, :sticker_ids, :allowed_mentions, :attachments)
      body[:content] = content if content
      request_options = files.empty? ? {} : {files: files}
      data = request(:post, "/channels/#{channel_id}/messages", body: MessagePayload.build(body), **request_options)
      Message.new(self, data)
    end

    def edit_message(channel_id, message_id, **options)
      body = options.slice(:content, :embeds, :components, :flags, :allowed_mentions, :attachments)
      request(:patch, "/channels/#{channel_id}/messages/#{message_id}", body: MessagePayload.build(body, edit: true, channel: true))
    end

    def pin_message(channel_id, message_id)
      request(:put, "/channels/#{channel_id}/pins/#{message_id}")
    end

    def unpin_message(channel_id, message_id)
      request(:delete, "/channels/#{channel_id}/pins/#{message_id}")
    end

    def fetch_pinned_messages(channel_id)
      data = request(:get, "/channels/#{channel_id}/pins")
      data.map { |m| Message.new(self, m) }
    end

    def delete_message(channel_id, message_id)
      request(:delete, "/channels/#{channel_id}/messages/#{message_id}")
    end

    def bulk_delete_messages(channel_id, message_ids)
      request(:post, "/channels/#{channel_id}/messages/bulk-delete", body: {messages: message_ids})
    end

    def crosspost_message(channel_id, message_id)
      request(:post, "/channels/#{channel_id}/messages/#{message_id}/crosspost")
    end

    def add_reaction(channel_id, message_id, emoji)
      encoded_emoji = URI.encode_www_form_component(emoji)
      request(:put, "/channels/#{channel_id}/messages/#{message_id}/reactions/#{encoded_emoji}/@me")
    end

    def remove_reaction(channel_id, message_id, emoji, user_id = '@me')
      encoded_emoji = URI.encode_www_form_component(emoji)
      request(:delete, "/channels/#{channel_id}/messages/#{message_id}/reactions/#{encoded_emoji}/#{user_id}")
    end

    def clear_reactions(channel_id, message_id)
      request(:delete, "/channels/#{channel_id}/messages/#{message_id}/reactions")
    end

    def fetch_reactions(channel_id, message_id, emoji, limit: 25, after: nil)
      params = {limit: limit}
      params[:after] = after if after
      encoded_emoji = URI.encode_www_form_component(emoji)
      request(:get, "/channels/#{channel_id}/messages/#{message_id}/reactions/#{encoded_emoji}", params: params)
    end

    def create_channel_invite(channel_id, **options)
      request(:post, "/channels/#{channel_id}/invites", body: options)
    end

    def fetch_channel_invites(channel_id)
      request(:get, "/channels/#{channel_id}/invites")
    end

    def delete_channel_invite(invite_code)
      request(:delete, "/invites/#{invite_code}")
    end

    def fetch_guild(guild_id)
      data = request(:get, "/guilds/#{guild_id}")
      Guild.new(self, data)
    end

    def edit_guild(guild_id, **options)
      request(:patch, "/guilds/#{guild_id}", body: options)
    end

    def delete_guild(guild_id)
      request(:delete, "/guilds/#{guild_id}")
    end

    def fetch_guild_channels(guild_id)
      data = request(:get, "/guilds/#{guild_id}/channels")
      data.map { |c| Channel.new(self, c) }
    end

    def create_guild_channel(guild_id, name, type, **options)
      data = request(:post, "/guilds/#{guild_id}/channels", body: options.merge(name: name, type: type))
      Channel.new(self, data)
    end

    def fetch_guild_member(guild_id, user_id)
      data = request(:get, "/guilds/#{guild_id}/members/#{user_id}")
      Member.new(self, data.merge('guild_id' => guild_id))
    end

    def list_guild_members(guild_id, limit: 1000, after: nil)
      params = {limit: limit}
      params[:after] = after if after
      data = request(:get, "/guilds/#{guild_id}/members", params: params)
      data.map { |m| Member.new(self, m.merge('guild_id' => guild_id)) }
    end

    def add_guild_member(guild_id, user_id, access_token:, **options)
      body = {access_token: access_token}.merge(options)
      data = request(:put, "/guilds/#{guild_id}/members/#{user_id}", body: body)
      data ? Member.new(self, data.merge('guild_id' => guild_id)) : nil
    end

    def modify_guild_member(guild_id, user_id, **options)
      data = request(:patch, "/guilds/#{guild_id}/members/#{user_id}", body: options)
      Member.new(self, data.merge('guild_id' => guild_id))
    end

    def remove_guild_member(guild_id, user_id, reason: nil)
      headers = reason ? {'X-Audit-Log-Reason' => reason} : {}
      request(:delete, "/guilds/#{guild_id}/members/#{user_id}", headers: headers)
    end

    def create_guild_ban(guild_id, user_id, delete_message_days: 0, reason: nil)
      headers = reason ? {'X-Audit-Log-Reason' => reason} : {}
      request(:put, "/guilds/#{guild_id}/bans/#{user_id}", body: {delete_message_days: delete_message_days}, headers: headers)
    end

    def remove_guild_ban(guild_id, user_id, reason: nil)
      headers = reason ? {'X-Audit-Log-Reason' => reason} : {}
      request(:delete, "/guilds/#{guild_id}/bans/#{user_id}", headers: headers)
    end

    def leave_guild(guild_id)
      request(:delete, "/users/@me/guilds/#{guild_id}")
    end

    def get_guild_prune_count(guild_id, days: 7, include_roles: nil)
      params = {days: days}
      params[:include_roles] = include_roles.join(',') if include_roles
      request(:get, "/guilds/#{guild_id}/prune", params: params)
    end

    def begin_guild_prune(guild_id, days: 7, compute_prune_count: true, include_roles: nil, reason: nil)
      body = {days: days, compute_prune_count: compute_prune_count}
      body[:include_roles] = include_roles if include_roles
      headers = reason ? {'X-Audit-Log-Reason' => reason} : {}
      request(:post, "/guilds/#{guild_id}/prune", body: body, headers: headers)
    end

    def add_guild_member_role(guild_id, user_id, role_id, reason: nil)
      headers = reason ? {'X-Audit-Log-Reason' => reason} : {}
      request(:put, "/guilds/#{guild_id}/members/#{user_id}/roles/#{role_id}", headers: headers)
    end

    def remove_guild_member_role(guild_id, user_id, role_id, reason: nil)
      headers = reason ? {'X-Audit-Log-Reason' => reason} : {}
      request(:delete, "/guilds/#{guild_id}/members/#{user_id}/roles/#{role_id}", headers: headers)
    end

    def fetch_guild_roles(guild_id)
      data = request(:get, "/guilds/#{guild_id}/roles")
      data.map { |r| Role.new(self, r.merge('guild_id' => guild_id)) }
    end

    def create_guild_role(guild_id, **options)
      data = request(:post, "/guilds/#{guild_id}/roles", body: options)
      Role.new(self, data.merge('guild_id' => guild_id))
    end

    def edit_guild_role(guild_id, role_id, **options)
      data = request(:patch, "/guilds/#{guild_id}/roles/#{role_id}", body: options)
      Role.new(self, data.merge('guild_id' => guild_id))
    end

    def delete_guild_role(guild_id, role_id)
      request(:delete, "/guilds/#{guild_id}/roles/#{role_id}")
    end

    def fetch_guild_emojis(guild_id)
      data = request(:get, "/guilds/#{guild_id}/emojis")
      data.map { |e| Emoji.new(self, e) }
    end

    def create_guild_emoji(guild_id, name:, image:, **options)
      data = request(:post, "/guilds/#{guild_id}/emojis", body: options.merge(name: name, image: image))
      Emoji.new(self, data)
    end

    def edit_guild_emoji(guild_id, emoji_id, **options)
      data = request(:patch, "/guilds/#{guild_id}/emojis/#{emoji_id}", body: options)
      Emoji.new(self, data)
    end

    def delete_guild_emoji(guild_id, emoji_id)
      request(:delete, "/guilds/#{guild_id}/emojis/#{emoji_id}")
    end

    def fetch_guild_stickers(guild_id)
      data = request(:get, "/guilds/#{guild_id}/stickers")
      data.map { |s| Sticker.new(self, s.merge('guild_id' => guild_id)) }
    end

    def fetch_guild_sticker(guild_id, sticker_id)
      data = request(:get, "/guilds/#{guild_id}/stickers/#{sticker_id}")
      Sticker.new(self, data.merge('guild_id' => guild_id))
    end

    def create_guild_sticker(guild_id, name:, description:, tags:, file:, **options)


      body = {name: name, description: description, tags: tags}
      body[:reason] = options[:reason] if options[:reason]
      request(:post, "/guilds/#{guild_id}/stickers", body: body)
    end

    def edit_guild_sticker(guild_id, sticker_id, **options)
      request(:patch, "/guilds/#{guild_id}/stickers/#{sticker_id}", body: options)
    end

    def delete_guild_sticker(guild_id, sticker_id)
      request(:delete, "/guilds/#{guild_id}/stickers/#{sticker_id}")
    end


    def list_voice_regions
      request(:get, '/voice/regions')
    end

    def fetch_guild_voice_regions(guild_id)
      request(:get, "/guilds/#{guild_id}/regions")
    end


    def fetch_guild_audit_log(guild_id, **params)
      request(:get, "/guilds/#{guild_id}/audit-logs", params: params)
    end


    def list_guild_scheduled_events(guild_id, with_user_count: false)
      request(:get, "/guilds/#{guild_id}/scheduled-events", params: {with_user_count: with_user_count})
    end

    def create_guild_scheduled_event(guild_id, **options)
      request(:post, "/guilds/#{guild_id}/scheduled-events", body: options)
    end

    def fetch_guild_scheduled_event(guild_id, event_id, with_user_count: false)
      request(:get, "/guilds/#{guild_id}/scheduled-events/#{event_id}", params: {with_user_count: with_user_count})
    end

    def edit_guild_scheduled_event(guild_id, event_id, **options)
      request(:patch, "/guilds/#{guild_id}/scheduled-events/#{event_id}", body: options)
    end

    def delete_guild_scheduled_event(guild_id, event_id)
      request(:delete, "/guilds/#{guild_id}/scheduled-events/#{event_id}")
    end

    def fetch_guild_scheduled_event_users(guild_id, event_id, limit: 100, with_member: false, before: nil, after: nil)
      params = {limit: limit, with_member: with_member}
      params[:before] = before if before
      params[:after] = after if after
      request(:get, "/guilds/#{guild_id}/scheduled-events/#{event_id}/users", params: params)
    end


    def fetch_guild_template(template_code)
      request(:get, "/guilds/templates/#{template_code}")
    end

    def create_guild_from_template(template_code, name, icon: nil)
      body = {name: name}
      body[:icon] = icon if icon
      request(:post, "/guilds/templates/#{template_code}", body: body)
    end

    def fetch_guild_templates(guild_id)
      request(:get, "/guilds/#{guild_id}/templates")
    end

    def create_guild_template(guild_id, name:, description: nil)
      body = {name: name, description: description}
      request(:post, "/guilds/#{guild_id}/templates", body: body)
    end

    def sync_guild_template(guild_id, template_code)
      request(:put, "/guilds/#{guild_id}/templates/#{template_code}")
    end

    def edit_guild_template(guild_id, template_code, **options)
      request(:patch, "/guilds/#{guild_id}/templates/#{template_code}", body: options)
    end

    def delete_guild_template(guild_id, template_code)
      request(:delete, "/guilds/#{guild_id}/templates/#{template_code}")
    end


    def fetch_guild_welcome_screen(guild_id)
      request(:get, "/guilds/#{guild_id}/welcome-screen")
    end

    def edit_guild_welcome_screen(guild_id, **options)
      request(:patch, "/guilds/#{guild_id}/welcome-screen", body: options)
    end


    def fetch_guild_onboarding(guild_id)
      request(:get, "/guilds/#{guild_id}/onboarding")
    end

    def edit_guild_onboarding(guild_id, **options)
      request(:patch, "/guilds/#{guild_id}/onboarding", body: options)
    end


    def list_entitlements(application_id, **params)
      request(:get, "/applications/#{application_id}/entitlements", params: params)
    end

    def create_test_entitlement(application_id, sku_id, owner_id, owner_type)
      body = {sku_id: sku_id, owner_id: owner_id, owner_type: owner_type}
      request(:post, "/applications/#{application_id}/entitlements", body: body)
    end

    def delete_test_entitlement(application_id, entitlement_id)
      request(:delete, "/applications/#{application_id}/entitlements/#{entitlement_id}")
    end


    def expire_poll(channel_id, message_id)
      request(:post, "/channels/#{channel_id}/messages/#{message_id}/poll/expire")
    end

    def fetch_poll_answer_voters(channel_id, message_id, answer_id, after: nil, limit: 100)
      params = {after: after, limit: limit}.compact
      request(:get, "/channels/#{channel_id}/messages/#{message_id}/poll/answers/#{answer_id}", params: params)
    end


    def start_thread_from_message(channel_id, message_id, name:, auto_archive_duration: nil, rate_limit_per_user: nil)
      body = {name: name}
      body[:auto_archive_duration] = auto_archive_duration if auto_archive_duration
      body[:rate_limit_per_user] = rate_limit_per_user if rate_limit_per_user
      request(:post, "/channels/#{channel_id}/messages/#{message_id}/threads", body: body)
    end

    def start_thread_without_message(channel_id, name:, auto_archive_duration: nil, type: nil, invitable: nil, rate_limit_per_user: nil)
      body = {name: name}
      body[:auto_archive_duration] = auto_archive_duration if auto_archive_duration
      body[:type] = type if type
      body[:invitable] = invitable unless invitable.nil?
      body[:rate_limit_per_user] = rate_limit_per_user if rate_limit_per_user
      request(:post, "/channels/#{channel_id}/threads", body: body)
    end

    def join_thread(channel_id)
      request(:put, "/channels/#{channel_id}/thread-members/@me")
    end

    def add_thread_member(channel_id, user_id)
      request(:put, "/channels/#{channel_id}/thread-members/#{user_id}")
    end

    def leave_thread(channel_id)
      request(:delete, "/channels/#{channel_id}/thread-members/@me")
    end

    def remove_thread_member(channel_id, user_id)
      request(:delete, "/channels/#{channel_id}/thread-members/#{user_id}")
    end

    def fetch_thread_member(channel_id, user_id)
      request(:get, "/channels/#{channel_id}/thread-members/#{user_id}")
    end

    def list_thread_members(channel_id)
      request(:get, "/channels/#{channel_id}/thread-members")
    end

    def list_active_threads(guild_id)
      request(:get, "/guilds/#{guild_id}/threads/active")
    end

    def list_public_archived_threads(channel_id, before: nil, limit: nil)
      params = {}
      params[:before] = before if before
      params[:limit] = limit if limit
      request(:get, "/channels/#{channel_id}/threads/archived/public", params: params)
    end

    def list_private_archived_threads(channel_id, before: nil, limit: nil)
      params = {}
      params[:before] = before if before
      params[:limit] = limit if limit
      request(:get, "/channels/#{channel_id}/threads/archived/private", params: params)
    end

    def list_joined_private_archived_threads(channel_id, before: nil, limit: nil)
      params = {}
      params[:before] = before if before
      params[:limit] = limit if limit
      request(:get, "/channels/#{channel_id}/users/@me/threads/archived/private", params: params)
    end


    def create_webhook(channel_id, name:, avatar: nil)
      body = {name: name}
      body[:avatar] = avatar if avatar
      request(:post, "/channels/#{channel_id}/webhooks", body: body)
    end

    def fetch_channel_webhooks(channel_id)
      request(:get, "/channels/#{channel_id}/webhooks")
    end

    def fetch_guild_webhooks(guild_id)
      request(:get, "/guilds/#{guild_id}/webhooks")
    end

    def fetch_webhook(webhook_id)
      request(:get, "/webhooks/#{webhook_id}")
    end

    def fetch_webhook_with_token(webhook_id, token)
      request(:get, "/webhooks/#{webhook_id}/#{token}")
    end

    def edit_webhook(webhook_id, name: nil, avatar: nil, channel_id: nil)
      body = {}
      body[:name] = name if name
      body[:avatar] = avatar if avatar
      body[:channel_id] = channel_id if channel_id
      request(:patch, "/webhooks/#{webhook_id}", body: body)
    end

    def delete_webhook(webhook_id)
      request(:delete, "/webhooks/#{webhook_id}")
    end


    def list_auto_moderation_rules(guild_id)
      request(:get, "/guilds/#{guild_id}/auto-moderation/rules")
    end

    def fetch_auto_moderation_rule(guild_id, rule_id)
      request(:get, "/guilds/#{guild_id}/auto-moderation/rules/#{rule_id}")
    end

    def create_auto_moderation_rule(guild_id, **options)
      request(:post, "/guilds/#{guild_id}/auto-moderation/rules", body: options)
    end

    def edit_auto_moderation_rule(guild_id, rule_id, **options)
      request(:patch, "/guilds/#{guild_id}/auto-moderation/rules/#{rule_id}", body: options)
    end

    def delete_auto_moderation_rule(guild_id, rule_id)
      request(:delete, "/guilds/#{guild_id}/auto-moderation/rules/#{rule_id}")
    end


    def create_stage_instance(channel_id, topic:, privacy_level: nil, send_start_notification: nil)
      body = {channel_id: channel_id, topic: topic}
      body[:privacy_level] = privacy_level if privacy_level
      body[:send_start_notification] = send_start_notification unless send_start_notification.nil?
      request(:post, '/stage-instances', body: body)
    end

    def fetch_stage_instance(channel_id)
      request(:get, "/stage-instances/#{channel_id}")
    end

    def edit_stage_instance(channel_id, topic: nil, privacy_level: nil)
      body = {}
      body[:topic] = topic if topic
      body[:privacy_level] = privacy_level if privacy_level
      request(:patch, "/stage-instances/#{channel_id}", body: body)
    end

    def delete_stage_instance(channel_id)
      request(:delete, "/stage-instances/#{channel_id}")
    end

    def create_dm_channel(user_id)
      request(:post, '/users/@me/channels', body: {recipient_id: user_id})
    end

    def send_dm(user_id, content, **options)
      channel = create_dm_channel(user_id)
      send_message(channel['id'], content, **options)
    end

    def fetch_application_commands(application_id, guild_id: nil)
      path = guild_id ? "/applications/#{application_id}/guilds/#{guild_id}/commands" : "/applications/#{application_id}/commands"
      request(:get, path)
    end

    def create_global_application_command(application_id, data)
      request(:post, "/applications/#{application_id}/commands", body: data)
    end

    def create_guild_application_command(application_id, guild_id, data)
      request(:post, "/applications/#{application_id}/guilds/#{guild_id}/commands", body: data)
    end

    def delete_application_command(application_id, command_id, guild_id: nil)
      path = guild_id ? "/applications/#{application_id}/guilds/#{guild_id}/commands/#{command_id}" : "/applications/#{application_id}/commands/#{command_id}"
      request(:delete, path)
    end

    def edit_application_command(application_id, command_id, data, guild_id: nil)
      path = guild_id ? "/applications/#{application_id}/guilds/#{guild_id}/commands/#{command_id}" : "/applications/#{application_id}/commands/#{command_id}"
      request(:patch, path, body: data)
    end

    def bulk_overwrite_global_application_commands(application_id, commands)
      request(:put, "/applications/#{application_id}/commands", body: commands)
    end

    def bulk_overwrite_guild_application_commands(application_id, guild_id, commands)
      request(:put, "/applications/#{application_id}/guilds/#{guild_id}/commands", body: commands)
    end

    def create_interaction_response(interaction_id, token, type, data = {})
      case type
      when Interaction::ResponseType::CHANNEL_MESSAGE_WITH_SOURCE
        data = MessagePayload.build(data)
      when Interaction::ResponseType::UPDATE_MESSAGE
        data = MessagePayload.build(data, edit: true)
      end
      request(:post, "/interactions/#{interaction_id}/#{token}/callback", body: {type: type, data: data})
    end

    def create_autocomplete_response(interaction_id, token, choices)
      body = {type: Interaction::ResponseType::APPLICATION_COMMAND_AUTOCOMPLETE_RESULT, data: {choices: choices}}
      request(:post, "/interactions/#{interaction_id}/#{token}/callback", body: body)
    end

    def create_modal_response(interaction_id, token, modal)
      payload = modal.respond_to?(:to_h) ? modal.to_h : modal
      create_interaction_response(interaction_id, token, Interaction::ResponseType::MODAL, payload)
    end

    def edit_original_interaction_response(application_id, token, data = {})
      request(:patch, "/webhooks/#{application_id}/#{token}/messages/@original", body: MessagePayload.build(data, edit: true))
    end

    def get_original_interaction_response(application_id, token)
      request(:get, "/webhooks/#{application_id}/#{token}/messages/@original")
    end

    def delete_original_interaction_response(application_id, token)
      request(:delete, "/webhooks/#{application_id}/#{token}/messages/@original")
    end

    def create_followup_message(application_id, token, data = {})
      request(:post, "/webhooks/#{application_id}/#{token}", body: MessagePayload.build(data))
    end

    def execute_webhook(webhook_id, webhook_token, data = {}, wait: false, thread_id: nil)
      body = MessagePayload.build(data)
      params = {wait: wait, thread_id: thread_id}.compact
      params[:with_components] = true if body[:components]
      request(:post, "/webhooks/#{webhook_id}/#{webhook_token}", params: params, body: body)
    end

    def edit_webhook_message(webhook_id, webhook_token, message_id, data = {}, thread_id: nil)
      body = MessagePayload.build(data, edit: true)
      params = {thread_id: thread_id}.compact
      params[:with_components] = true if body[:components]
      request(:patch, "/webhooks/#{webhook_id}/#{webhook_token}/messages/#{message_id}", params: params, body: body)
    end

    def delete_webhook_message(webhook_id, webhook_token, message_id)
      request(:delete, "/webhooks/#{webhook_id}/#{webhook_token}/messages/#{message_id}")
    end

    private

    def parse_response(response)
      body = response.body && !response.body.empty? ? JSON.parse(response.body) : {}

      if response.code.to_i >= 400
        warn "[ERROR] Discord API error #{response.code}: #{body.inspect}"
        raise "Discord API error #{response.code}: #{body.inspect}"
      end

      body
    rescue JSON::ParserError
      response.body
    end
  end
end
