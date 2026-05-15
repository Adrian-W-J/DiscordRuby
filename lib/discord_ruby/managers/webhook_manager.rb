module DiscordRuby
  module Managers
    class WebhookManager < CachedManager
      attr_reader :guild_id, :channel_id

      def initialize(bot, guild_id: nil, channel_id: nil)
        super(bot)
        @guild_id = guild_id
        @channel_id = channel_id
      end

      def fetch_all(cache: true)
        if @channel_id
          data = @bot.api.get_channel_webhooks(@channel_id)
        elsif @guild_id
          data = @bot.api.get_guild_webhooks(@guild_id)
        else
          return []
        end
        webhooks = data.map { |d| Webhook.new(@bot, d) }
        webhooks.each { |w| @cache[w.id] = w } if cache
        webhooks
      end

      def fetch(id, cache: true)
        data = @bot.api.get_webhook(id)
        webhook = Webhook.new(@bot, data)
        @cache[id] = webhook if cache
        webhook
      end

      def create(name:, avatar: nil, reason: nil)
        return nil unless @channel_id
        data = @bot.api.create_webhook(@channel_id, name: name, avatar: avatar, reason: reason)
        webhook = Webhook.new(@bot, data)
        @cache[webhook.id] = webhook
        webhook
      end

      def edit(id, **options)
        data = @bot.api.modify_webhook(id, **options)
        webhook = Webhook.new(@bot, data)
        @cache[id] = webhook
        webhook
      end

      def delete(id, reason: nil)
        @bot.api.delete_webhook(id, reason: reason)
        @cache.delete(id)
      end
    end
  end
end
