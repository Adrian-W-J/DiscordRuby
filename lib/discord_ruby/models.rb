module DiscordRuby
  class Permissions
    FLAGS = {
      create_instant_invite: 1 << 0,
      kick_members: 1 << 1,
      ban_members: 1 << 2,
      administrator: 1 << 3,
      manage_channels: 1 << 4,
      manage_guild: 1 << 5,
      add_reactions: 1 << 6,
      view_audit_log: 1 << 7,
      priority_speaker: 1 << 8,
      stream: 1 << 9,
      view_channel: 1 << 10,
      send_messages: 1 << 11,
      send_tts_messages: 1 << 12,
      manage_messages: 1 << 13,
      embed_links: 1 << 14,
      attach_files: 1 << 15,
      read_message_history: 1 << 16,
      mention_everyone: 1 << 17,
      use_external_emojis: 1 << 18,
      view_guild_insights: 1 << 19,
      connect: 1 << 20,
      speak: 1 << 21,
      mute_members: 1 << 22,
      deafen_members: 1 << 23,
      move_members: 1 << 24,
      use_vad: 1 << 25,
      change_nickname: 1 << 26,
      manage_nicknames: 1 << 27,
      manage_roles: 1 << 28,
      manage_webhooks: 1 << 29,
      manage_guild_expressions: 1 << 30,
      use_application_commands: 1 << 31,
      request_to_speak: 1 << 32,
      manage_events: 1 << 33,
      manage_threads: 1 << 34,
      create_public_threads: 1 << 35,
      create_private_threads: 1 << 36,
      use_external_stickers: 1 << 37,
      send_messages_in_threads: 1 << 38,
      use_embedded_activities: 1 << 39,
      moderate_members: 1 << 40,
      view_creator_monetization_analytics: 1 << 41,
      use_soundboard: 1 << 42,
      use_external_sounds: 1 << 45,
      send_voice_messages: 1 << 46
    }.freeze

    attr_reader :bitfield

    def initialize(bitfield = 0)
      @bitfield = bitfield.to_i
    end

    def has?(permission)
      flag = FLAGS[permission.to_sym]
      return false unless flag
      (@bitfield & flag) == flag || (@bitfield & FLAGS[:administrator]) == FLAGS[:administrator]
    end

    def to_a
      FLAGS.keys.select { |k| has?(k) }
    end
  end

  class BaseModel
    attr_reader :bot, :data

    def initialize(bot, data)
      @bot = bot
      @data = data
      update_data(data)
    end

    def update_data(data)
      @data.merge!(data)
      data.each do |key, value|
        instance_variable_set("@#{key}", value) if respond_to?(key.to_sym)
      end
    end

    def id
      (@data[:id] || @data['id']).to_s
    end

    def to_h
      @data
    end

    def inspect
      "#<#{self.class}:#{id}>"
    end
  end

  class User < BaseModel
    attr_reader :username, :discriminator, :avatar, :bot_user, :system, :mfa_enabled, :banner, :accent_color, :locale, :verified, :email, :flags, :premium_type, :public_flags

    def initialize(bot, data)
      super
      @bot_user = data['bot']
    end

    def tag
      "#{@username}#{@discriminator && @discriminator != '0' ? "##{@discriminator}" : ""}"
    end

    def mention
      "<@#{id}>"
    end

    def avatar_url(size: 1024, format: 'png')
      return nil unless @avatar
      "https://cdn.discordapp.com/avatars/#{id}/#{@avatar}.#{format}?size=#{size}"
    end

    def send_dm(content, **options)
      @bot.send_dm(id, content, **options)
    end
  end

  class Role < BaseModel
    attr_reader :name, :color, :hoist, :icon, :unicode_emoji, :position, :permissions, :managed, :mentionable, :tags, :guild_id

    def initialize(bot, data)
      super
      @permissions = Permissions.new(data['permissions'])
    end

    def mention
      "<@&#{id}>"
    end
  end

  class Emoji < BaseModel
    attr_reader :name, :roles, :user, :require_colons, :managed, :animated, :available

    def mention
      @animated ? "<a:#{name}:#{id}>" : "<:#{name}:#{id}>"
    end
  end

  class Attachment < BaseModel
    attr_reader :filename, :description, :content_type, :size, :url, :proxy_url, :height, :width, :ephemeral, :duration_secs, :waveform
  end

  class Sticker < BaseModel
    attr_reader :pack_id, :name, :description, :tags, :asset, :type, :format_type, :available, :guild_id, :user, :sort_value
  end

  class Presence < BaseModel
    attr_reader :user, :guild_id, :status, :activities, :client_status

    def initialize(bot, data)
      super
      @user = bot.users.get(data['user']['id']) || User.new(bot, data['user']) if data['user']
    end
  end

  class ScheduledEvent < BaseModel
    attr_reader :guild_id, :channel_id, :creator_id, :name, :description, :scheduled_start_time, :scheduled_end_time, :privacy_level, :status, :entity_type, :entity_id, :entity_metadata, :creator, :user_count, :image

    def delete
      @bot.delete_guild_scheduled_event(@guild_id, id)
    end
  end

  class StageInstance < BaseModel
    attr_reader :guild_id, :channel_id, :topic, :privacy_level, :discoverable_disabled, :guild_scheduled_event_id

    def delete
      @bot.delete_stage_instance(@channel_id)
    end
  end

  class PollAnswer < BaseModel
    attr_reader :answer_id, :poll_media

    def text
      @poll_media['text']
    end

    def emoji
      @poll_media['emoji']
    end
  end

  class Poll < BaseModel
    attr_reader :question, :answers, :expiry, :allow_multiselect, :layout_type, :results

    def initialize(bot, data)
      super
      @answers = (data['answers'] || []).map { |a| PollAnswer.new(bot, a) }
    end
  end

  class Reaction
    attr_reader :count, :me, :emoji

    def initialize(bot, data)
      @bot = bot
      @count = data['count']
      @me = data['me']
      @emoji = data['emoji']['id'] ? Emoji.new(bot, data['emoji']) : data['emoji']['name']
    end
  end

  class Message < BaseModel
    attr_reader :channel_id, :guild_id, :author, :member, :content, :timestamp, :edited_timestamp, :tts, :mention_everyone, :mentions, :mention_roles, :mention_channels, :attachments, :embeds, :reactions, :nonce, :pinned, :webhook_id, :type, :activity, :application, :application_id, :message_reference, :flags, :referenced_message, :interaction, :thread, :components, :sticker_items, :stickers, :position, :role_subscription_data, :resolved, :poll

    def initialize(bot, data)
      super
      @author = User.new(bot, data['author']) if data['author']
      @member = Member.new(bot, data['member'].merge('guild_id' => data['guild_id'])) if data['member'] && data['guild_id']
      @attachments = (data['attachments'] || []).map { |a| Attachment.new(bot, a) }
      @reactions = (data['reactions'] || []).map { |r| Reaction.new(bot, r) }
      @sticker_items = (data['sticker_items'] || []).map { |s| Sticker.new(bot, s) }
      @poll = Poll.new(bot, data['poll']) if data['poll']
    end

    def reply(content: nil, **options)
      if @data['token']
        @bot.reply(self, content: content, **options)
      else
        options[:message_reference] ||= { message_id: id }
        @bot.send_message(@channel_id, content, **options)
      end
    end

    def delete
      @bot.delete_message(@channel_id, id)
    end

    def edit(content: nil, **options)
      @bot.edit_message(@channel_id, id, content: content, **options)
    end

    def add_reaction(emoji)
      @bot.add_reaction(@channel_id, id, emoji)
    end

    def start_thread(name:, auto_archive_duration: nil)
      @bot.start_thread_from_message(@channel_id, id, name: name, auto_archive_duration: auto_archive_duration)
    end

    def pin
      @bot.pin_message(@channel_id, id)
    end

    def unpin
      @bot.unpin_message(@channel_id, id)
    end

    def channel
      @bot.channels.get(channel_id) || @bot.fetch_channel(channel_id)
    end

    def guild
      @bot.guilds.get(guild_id) if guild_id
    end
  end

  class Guild < BaseModel
    attr_reader :name, :icon, :icon_hash, :splash, :discovery_splash, :owner, :owner_id, :permissions, :region, :afk_channel_id, :afk_timeout, :widget_enabled, :widget_channel_id, :verification_level, :default_message_notifications, :explicit_content_filter, :roles, :emojis, :features, :mfa_level, :application_id, :system_channel_id, :system_channel_flags, :rules_channel_id, :max_presences, :max_members, :vanity_url_code, :description, :banner, :premium_tier, :premium_subscription_count, :preferred_locale, :public_updates_channel_id, :max_video_channel_users, :max_stage_video_channel_users, :approximate_member_count, :approximate_presence_count, :welcome_screen, :nsfw_level, :stickers, :premium_progress_bar_enabled, :safety_alerts_channel_id

    def initialize(bot, data)
      super
      @roles = (data['roles'] || []).map { |r| Role.new(bot, r.merge('guild_id' => id)) }
      @emojis = (data['emojis'] || []).map { |e| Emoji.new(bot, e) }
      @stickers = (data['stickers'] || []).map { |s| Sticker.new(bot, s.merge('guild_id' => id)) }
    end

    def fetch_channels
      @bot.fetch_guild_channels(id).map { |c| Channel.new(@bot, c) }
    end

    def fetch_members(limit: 1000, after: nil)
      @bot.list_guild_members(id, limit: limit, after: after).map { |m| Member.new(@bot, m.merge('guild_id' => id)) }
    end

    def fetch_audit_logs(**params)
      @bot.fetch_guild_audit_log(id, **params)
    end

    def prune_count(days: 7, include_roles: nil)
      @bot.get_guild_prune_count(id, days: days, include_roles: include_roles)
    end

    def prune(days: 7, compute_prune_count: true, include_roles: nil, reason: nil)
      @bot.begin_guild_prune(id, days: days, compute_prune_count: compute_prune_count, include_roles: include_roles, reason: reason)
    end

    def fetch_active_threads
      @bot.list_active_threads(id)
    end

    def leave
      @bot.leave_guild(id)
    end
  end

  class Member < BaseModel
    attr_reader :user, :nick, :avatar, :roles, :joined_at, :premium_since, :deaf, :mute, :flags, :pending, :permissions, :communication_disabled_until, :guild_id

    def initialize(bot, data)
      super
      @user = User.new(bot, data['user']) if data['user']
      @permissions = Permissions.new(data['permissions']) if data['permissions']
    end

    def id
      @user&.id || super
    end

    def mention
      @nick ? "<@!#{id}>" : "<@#{id}>"
    end

    def timeout(until_time, reason: nil)
      iso_time = until_time.respond_to?(:iso8601) ? until_time.iso8601 : until_time
      @bot.modify_guild_member(@guild_id, id, communication_disabled_until: iso_time, reason: reason)
    end

    def set_nickname(nick, reason: nil)
      @bot.modify_guild_member(@guild_id, id, nick: nick, reason: reason)
    end

    def add_role(role_id, reason: nil)
      @bot.add_guild_member_role(@guild_id, id, role_id, reason: reason)
    end

    def remove_role(role_id, reason: nil)
      @bot.remove_guild_member_role(@guild_id, id, role_id, reason: reason)
    end

    def kick(reason: nil)
      @bot.remove_guild_member(@guild_id, id, reason: reason)
    end

    def ban(delete_message_days: 0, reason: nil)
      @bot.create_guild_ban(@guild_id, id, delete_message_days: delete_message_days, reason: reason)
    end
  end

  class Channel < BaseModel
    attr_reader :type, :guild_id, :position, :permission_overwrites, :name, :topic, :nsfw, :last_message_id, :bitrate, :user_limit, :rate_limit_per_user, :recipients, :icon, :owner_id, :application_id, :managed, :parent_id, :last_pin_timestamp, :rtc_region, :video_quality_mode, :message_count, :member_count, :thread_metadata, :member, :default_auto_archive_duration, :permissions, :flags, :total_message_sent, :available_tags, :applied_tags, :default_reaction_emoji, :default_thread_rate_limit_per_user, :default_sort_order, :default_forum_layout

    def send_message(content, **options)
      @bot.send_message(id, content, **options)
    end

    def fetch_messages(limit: 50)
      @bot.fetch_channel_messages(id, limit: limit).map { |m| Message.new(@bot, m) }
    end

    def fetch_pinned_messages
      @bot.fetch_pinned_messages(id)
    end

    def create_thread(name:, type: nil, auto_archive_duration: nil)
      @bot.start_thread_without_message(id, name: name, type: type, auto_archive_duration: auto_archive_duration)
    end

    def join
      @bot.join_thread(id)
    end

    def leave
      @bot.leave_thread(id)
    end

    def add_member(user_id)
      @bot.add_thread_member(id, user_id)
    end

    def remove_member(user_id)
      @bot.remove_thread_member(id, user_id)
    end

    def thread?
      [10, 11, 12].include?(@type)
    end

    def delete
      @bot.delete_channel(id)
    end
  end
end
