module DiscordRuby
  module Managers
    class BanManager < BaseManager
      attr_reader :guild_id

      def initialize(bot, guild_id)
        super(bot)
        @guild_id = guild_id
      end

      def fetch_all(limit: 1000, before: nil, after: nil)
        @bot.api.get_guild_bans(@guild_id, limit: limit, before: before, after: after).map do |data|
          {
            reason: data['reason'],
            user: User.new(@bot, data['user'])
          }
        end
      end

      def fetch(user_id)
        data = @bot.api.get_guild_ban(@guild_id, user_id)
        {
          reason: data['reason'],
          user: User.new(@bot, data['user'])
        }
      end

      def create(user_id, delete_message_seconds: 0, reason: nil)
        @bot.api.create_guild_ban(@guild_id, user_id, delete_message_seconds: delete_message_seconds, reason: reason)
      end

      def remove(user_id, reason: nil)
        @bot.api.remove_guild_ban(@guild_id, user_id, reason: reason)
      end
    end
  end
end
