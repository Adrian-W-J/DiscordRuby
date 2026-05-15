module DiscordRuby
  module Managers
    class GuildScheduledEventManager < CachedManager
      attr_reader :guild_id

      def initialize(bot, guild_id)
        super(bot)
        @guild_id = guild_id
      end

      def fetch_all(with_user_count: false, cache: true)
        data = @bot.api.get_guild_scheduled_events(@guild_id, with_user_count: with_user_count)
        events = data.map { |d| ScheduledEvent.new(@bot, d) }
        events.each { |e| @cache[e.id] = e } if cache
        events
      end

      def fetch(id, with_user_count: false, cache: true)
        data = @bot.api.get_guild_scheduled_event(@guild_id, id, with_user_count: with_user_count)
        event = ScheduledEvent.new(@bot, data)
        @cache[id] = event if cache
        event
      end

      def create(**options)
        data = @bot.api.create_guild_scheduled_event(@guild_id, **options)
        event = ScheduledEvent.new(@bot, data)
        @cache[event.id] = event
        event
      end

      def edit(id, **options)
        data = @bot.api.modify_guild_scheduled_event(@guild_id, id, **options)
        event = ScheduledEvent.new(@bot, data)
        @cache[id] = event
        event
      end

      def delete(id)
        @bot.api.delete_guild_scheduled_event(@guild_id, id)
        @cache.delete(id)
      end
    end
  end
end
