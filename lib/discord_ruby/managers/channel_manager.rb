module DiscordRuby
  module Managers
    class ChannelManager < CachedManager
      def fetch(id, cache: true)
        data = @bot.api.get_channel(id)
        channel = Channel.from_data(@bot, data)
        @cache[id] = channel if cache
        channel
      end

      def create(guild_id, **options)
        data = @bot.api.create_guild_channel(guild_id, **options)
        channel = Channel.from_data(@bot, data)
        @cache[channel.id] = channel
        channel
      end

      def edit(id, **options)
        data = @bot.api.modify_channel(id, **options)
        channel = Channel.from_data(@bot, data)
        @cache[id] = channel
        channel
      end

      def delete(id, reason: nil)
        @bot.api.delete_channel(id, reason: reason)
        @cache.delete(id)
      end
    end
  end
end
