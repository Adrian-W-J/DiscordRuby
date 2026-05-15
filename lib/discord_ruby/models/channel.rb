module DiscordRuby
  class Channel < BaseModel
    attr_reader :name, :type, :position, :permission_overwrites, :guild_id

    def self.from_data(bot, data)
      type = data['type']
      case type
      when 0, 5 then TextChannel.new(bot, data)
      when 2, 13 then VoiceChannel.new(bot, data)
      when 4 then CategoryChannel.new(bot, data)
      when 10, 11, 12 then ThreadChannel.new(bot, data)
      when 15 then ForumChannel.new(bot, data)
      when 16 then MediaChannel.new(bot, data)
      else Channel.new(bot, data)
      end
    end

    def initialize(bot, data)
      super
      @type = data['type']
      @guild_id = data['guild_id']
    end

    def mention
      "<##{id}>"
    end

    def delete(reason: nil)
      @bot.api.delete_channel(id)
    end

    def edit(**options)
      data = @bot.api.request(:patch, "/channels/#{id}", body: options)
      update_data(data)
      self
    end

    def fetch
      data = @bot.api.fetch_channel(id)
      update_data(data)
      self
    end

    def guild
      @bot.guilds.cache[@guild_id] if @guild_id
    end

    def text?
      [0, 5, 10, 11, 12, 15].include?(@type)
    end

    def voice?
      [2, 13].include?(@type)
    end

    def thread?
      [10, 11, 12].include?(@type)
    end

    def category?
      @type == 4
    end
  end

  class TextChannel < Channel
    attr_reader :topic, :last_message_id, :rate_limit_per_user, :parent_id, :last_pin_timestamp, :nsfw

    def send_message(content, **options)
      @bot.send_message(id, content, **options)
    end

    def send_typing
      @bot.api.request(:post, "/channels/#{id}/typing")
    end

    def fetch_messages(limit: 50, before: nil, after: nil, around: nil)
      @bot.api.fetch_channel_messages(id, limit: limit, before: before, after: after, around: around).map { |m| Message.new(@bot, m) }
    end

    def bulk_delete(messages)
      ids = messages.map { |m| m.respond_to?(:id) ? m.id : m }
      @bot.api.bulk_delete_messages(id, ids)
    end

    def create_invite(**options)
      @bot.api.create_channel_invite(id, **options)
    end

    def fetch_invites
      @bot.api.fetch_channel_invites(id).map { |i| Invite.new(@bot, i) }
    end

    def create_webhook(name, avatar: nil)
      @bot.api.create_webhook(id, name, avatar: avatar)
    end

    def fetch_webhooks
      @bot.api.fetch_channel_webhooks(id).map { |w| Webhook.new(@bot, w) }
    end

    def fetch_pinned_messages
      @bot.api.fetch_pinned_messages(id).map { |m| Message.new(@bot, m) }
    end

    def create_thread(name, **options)
      data = @bot.api.start_thread_without_message(id, name: name, **options)
      ThreadChannel.new(@bot, data)
    end
  end

  class VoiceChannel < Channel
    attr_reader :bitrate, :user_limit, :rtc_region, :video_quality_mode

    def connect
      @bot.gateway.voice_state_update(@guild_id, id)
    end
  end

  class CategoryChannel < Channel
    def children
      guild&.channels&.select { |c| c.parent_id == id } || []
    end
  end

  class ThreadChannel < TextChannel
    attr_reader :message_count, :member_count, :thread_metadata, :member

    def join
      @bot.api.join_thread(id)
    end

    def leave
      @bot.api.leave_thread(id)
    end

    def add_member(user_id)
      @bot.api.add_thread_member(id, user_id)
    end

    def remove_member(user_id)
      @bot.api.remove_thread_member(id, user_id)
    end
  end

  class ForumChannel < Channel
    attr_reader :available_tags, :default_reaction_emoji, :default_thread_rate_limit_per_user, :default_sort_order, :default_forum_layout

    def create_post(name, content, **options)
      @bot.api.request(:post, "/channels/#{id}/threads", body: {name: name, message: {content: content}.merge(options)})
    end

    def threads
      @threads ||= Managers::ThreadManager.new(@bot, id)
    end
  end

  class MediaChannel < ForumChannel
  end

  module ChannelHelpers
    def messages
      @messages ||= Managers::MessageManager.new(@bot, id)
    end

    def webhooks
      @webhooks ||= Managers::WebhookManager.new(@bot, channel_id: id)
    end

    def invites
      @invites ||= Managers::InviteManager.new(@bot, channel_id: id)
    end

    def permission_overwrites_manager
      @permission_overwrites_manager ||= Managers::PermissionOverwriteManager.new(@bot, id)
    end
  end

  class TextChannel
    include ChannelHelpers
  end

  class VoiceChannel
    include ChannelHelpers
  end

  class CategoryChannel
    include ChannelHelpers
  end

  class ThreadChannel
    def members
      @members ||= Managers::ThreadMemberManager.new(@bot, id)
    end
  end
end
