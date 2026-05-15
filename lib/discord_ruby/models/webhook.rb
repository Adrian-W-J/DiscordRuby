module DiscordRuby
  class Webhook < BaseModel
    attr_reader :type, :guild_id, :channel_id, :user, :name, :avatar, :token, :application_id, :source_guild, :source_channel, :url

    def initialize(bot, data)
      super
      @user = User.new(bot, data['user']) if data['user']
    end

    def guild
      @bot.guilds.cache[@guild_id] if @guild_id
    end

    def channel
      @bot.channels.cache[@channel_id] if @channel_id
    end

    def send(content = nil, **options, &block)
      @bot.api.execute_webhook(id, @token, content: content, **options, &block)
    end

    def edit(name: nil, avatar: nil, channel_id: nil, reason: nil)
      @bot.api.modify_webhook(id, name: name, avatar: avatar, channel_id: channel_id, reason: reason)
    end

    def delete(reason: nil)
      @bot.api.delete_webhook(id, reason: reason)
    end

    def set_name(name)
      edit(name: name)
    end

    def set_avatar(avatar)
      edit(avatar: avatar)
    end

    def fetch_message(message_id, thread_id: nil)
      @bot.api.get_webhook_message(id, @token, message_id, thread_id: thread_id)
    end

    def edit_message(message_id, content = nil, **options, &block)
      @bot.api.edit_webhook_message(id, @token, message_id, content: content, **options, &block)
    end

    def delete_message(message_id, thread_id: nil)
      @bot.api.delete_webhook_message(id, @token, message_id, thread_id: thread_id)
    end
  end
end
