module DiscordRuby
  module Managers
    class PresenceManager < CachedManager
      attr_reader :guild_id

      def initialize(bot, guild_id)
        super(bot)
        @guild_id = guild_id
      end

      def set(status:, activities: [], afk: false, since: nil)
        @bot.gateway.send_presence(status: status, activities: activities, afk: afk, since: since)
      end
    end
  end
end
