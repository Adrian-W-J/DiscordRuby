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

    def request(method, path, params: nil, body: nil, headers: {})
      uri = URI.join(DiscordRuby::API_BASE, path)
      uri.query = URI.encode_www_form(params) if params && !params.empty?

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
      request.body = JSON.generate(body) if body

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end

      parse_response(response)
    end

    def fetch_my_user
      request(:get, '/users/@me')
    end

    def fetch_user(user_id)
      request(:get, "/users/#{user_id}")
    end

    def modify_current_user(username: nil, avatar: nil)
      body = {}
      body[:username] = username if username
      body[:avatar] = avatar if avatar
      request(:patch, '/users/@me', body: body)
    end

    def fetch_channel(channel_id)
      request(:get, "/channels/#{channel_id}")
    end

    def fetch_channel_messages(channel_id, limit: 50, before: nil, after: nil, around: nil)
      params = {limit: limit}
      params[:before] = before if before
      params[:after] = after if after
      params[:around] = around if around
      request(:get, "/channels/#{channel_id}/messages", params: params)
    end

    def send_message(channel_id, content, **options)
      raise ArgumentError, 'Message content cannot be blank' if content.nil? || content.to_s.strip.empty?

      body = {content: content}
      body[:tts] = options[:tts] if options.key?(:tts)
      body[:embeds] = options[:embeds] if options.key?(:embeds)
      body[:components] = options[:components] if options.key?(:components)
      body[:flags] = options[:flags] if options.key?(:flags)
      request(:post, "/channels/#{channel_id}/messages", body: body)
    end

    def edit_message(channel_id, message_id, content: nil, **options)
      body = {}
      body[:content] = content if content
      body[:embeds] = options[:embeds] if options.key?(:embeds)
      body[:components] = options[:components] if options.key?(:components)
      body[:flags] = options[:flags] if options.key?(:flags)
      request(:patch, "/channels/#{channel_id}/messages/#{message_id}", body: body)
    end

    def delete_message(channel_id, message_id)
      request(:delete, "/channels/#{channel_id}/messages/#{message_id}")
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
      request(:get, "/guilds/#{guild_id}")
    end

    def edit_guild(guild_id, **options)
      request(:patch, "/guilds/#{guild_id}", body: options)
    end

    def delete_guild(guild_id)
      request(:delete, "/guilds/#{guild_id}")
    end

    def fetch_guild_channels(guild_id)
      request(:get, "/guilds/#{guild_id}/channels")
    end

    def create_guild_channel(guild_id, name, type, **options)
      request(:post, "/guilds/#{guild_id}/channels", body: options.merge(name: name, type: type))
    end

    def fetch_guild_member(guild_id, user_id)
      request(:get, "/guilds/#{guild_id}/members/#{user_id}")
    end

    def list_guild_members(guild_id, limit: 1000, after: nil)
      params = {limit: limit}
      params[:after] = after if after
      request(:get, "/guilds/#{guild_id}/members", params: params)
    end

    def add_guild_member(guild_id, user_id, access_token:, **options)
      body = {access_token: access_token}.merge(options)
      request(:put, "/guilds/#{guild_id}/members/#{user_id}", body: body)
    end

    def modify_guild_member(guild_id, user_id, **options)
      request(:patch, "/guilds/#{guild_id}/members/#{user_id}", body: options)
    end

    def remove_guild_member(guild_id, user_id)
      request(:delete, "/guilds/#{guild_id}/members/#{user_id}")
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
      request(:get, "/guilds/#{guild_id}/roles")
    end

    def create_guild_role(guild_id, **options)
      request(:post, "/guilds/#{guild_id}/roles", body: options)
    end

    def edit_guild_role(guild_id, role_id, **options)
      request(:patch, "/guilds/#{guild_id}/roles/#{role_id}", body: options)
    end

    def delete_guild_role(guild_id, role_id)
      request(:delete, "/guilds/#{guild_id}/roles/#{role_id}")
    end

    def fetch_guild_emojis(guild_id)
      request(:get, "/guilds/#{guild_id}/emojis")
    end

    def create_guild_emoji(guild_id, name:, image:, **options)
      request(:post, "/guilds/#{guild_id}/emojis", body: options.merge(name: name, image: image))
    end

    def edit_guild_emoji(guild_id, emoji_id, **options)
      request(:patch, "/guilds/#{guild_id}/emojis/#{emoji_id}", body: options)
    end

    def delete_guild_emoji(guild_id, emoji_id)
      request(:delete, "/guilds/#{guild_id}/emojis/#{emoji_id}")
    end

    def fetch_guild_stickers(guild_id)
      request(:get, "/guilds/#{guild_id}/stickers")
    end

    def fetch_guild_sticker(guild_id, sticker_id)
      request(:get, "/guilds/#{guild_id}/stickers/#{sticker_id}")
    end

    def create_guild_sticker(guild_id, name:, description:, tags:, file:, **options)
      request(:post, "/guilds/#{guild_id}/stickers", body: options.merge(name: name, description: description, tags: tags, file: file))
    end

    def edit_guild_sticker(guild_id, sticker_id, **options)
      request(:patch, "/guilds/#{guild_id}/stickers/#{sticker_id}", body: options)
    end

    def delete_guild_sticker(guild_id, sticker_id)
      request(:delete, "/guilds/#{guild_id}/stickers/#{sticker_id}")
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

    def create_interaction_response(interaction_id, token, type, data = {})
      request(:post, "/interactions/#{interaction_id}/#{token}/callback", body: {type: type, data: data})
    end

    def edit_original_interaction_response(application_id, token, data = {})
      request(:patch, "/webhooks/#{application_id}/#{token}/messages/@original", body: data)
    end

    def delete_original_interaction_response(application_id, token)
      request(:delete, "/webhooks/#{application_id}/#{token}/messages/@original")
    end

    def create_followup_message(application_id, token, data = {})
      request(:post, "/webhooks/#{application_id}/#{token}", body: data)
    end

    def execute_webhook(webhook_id, webhook_token, data = {}, wait: false)
      request(:post, "/webhooks/#{webhook_id}/#{webhook_token}", params: {wait: wait}, body: data)
    end

    def edit_webhook_message(webhook_id, webhook_token, message_id, data = {})
      request(:patch, "/webhooks/#{webhook_id}/#{webhook_token}/messages/#{message_id}", body: data)
    end

    def delete_webhook_message(webhook_id, webhook_token, message_id)
      request(:delete, "/webhooks/#{webhook_id}/#{webhook_token}/messages/#{message_id}")
    end

    private

    def parse_response(response)
      body = response.body && !response.body.empty? ? JSON.parse(response.body) : {}

      if response.code.to_i >= 400
        raise "Discord API error #{response.code}: #{body.inspect}"
      end

      body
    rescue JSON::ParserError
      response.body
    end
  end
end
