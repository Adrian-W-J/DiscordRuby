module DiscordRuby
  class Webhook < BaseModel
    attr_reader :type, :guild_id, :channel_id, :user, :name, :avatar, :token, :application_id, :source_guild, :source_channel, :url

    def initialize(bot, data)
      super
      @user = User.new(bot, data['user']) if data['user']
    end

    def guild
      @bot.guilds.get(@guild_id) if @guild_id && @bot.respond_to?(:guilds)
    end

    def channel
      @bot.channels.get(@channel_id) if @channel_id && @bot.respond_to?(:channels)
    end

    def send(content = nil, wait: true, thread_id: nil, files: {}, **options)
      options[:content] = content unless content.nil?
      data = @bot.execute_webhook(id, webhook_token, options, wait: wait, thread_id: thread_id, files: files)
      Message.new(@bot, data) if wait
    end

    def edit(**options)
      Webhook.new(@bot, @bot.edit_webhook(id, **options))
    end

    def delete
      @bot.delete_webhook(id)
    end

    def set_name(name)
      edit(name: name)
    end

    def set_avatar(avatar)
      edit(avatar: avatar)
    end

    def fetch_message(message_id, thread_id: nil)
      Message.new(@bot, @bot.fetch_webhook_message(id, webhook_token, message_id, thread_id: thread_id))
    end

    def edit_message(message_id, content = nil, thread_id: nil, files: {}, **options)
      options[:content] = content unless content.nil?
      data = @bot.edit_webhook_message(id, webhook_token, message_id, options, thread_id: thread_id, files: files)
      Message.new(@bot, data)
    end

    def delete_message(message_id, thread_id: nil)
      @bot.delete_webhook_message(id, webhook_token, message_id, thread_id: thread_id)
    end

    private

    def webhook_token
      @token || raise(ArgumentError, 'this webhook has no token')
    end
  end
end
