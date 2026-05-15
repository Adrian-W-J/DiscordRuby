module DiscordRuby
  class GuildWebhookManager < CachedManager
    attr_reader :guild

    def initialize(guild)
      super(guild.bot, Webhook)
      @guild = guild
    end

    def fetch_all
      data = @bot.fetch_guild_webhooks(@guild.id)
      data.map { |w| add(w) }
    end

    def create(channel_id:, name:, avatar: nil)
      data = @bot.create_webhook(channel_id, name: name, avatar: avatar)
      add(data)
    end
  end

  class ChannelWebhookManager < CachedManager
    attr_reader :channel

    def initialize(channel)
      super(channel.bot, Webhook)
      @channel = channel
    end

    def fetch_all
      data = @bot.fetch_channel_webhooks(@channel.id)
      data.map { |w| add(w) }
    end

    def create(name:, avatar: nil)
      data = @bot.create_webhook(@channel.id, name: name, avatar: avatar)
      add(data)
    end
  end
end
