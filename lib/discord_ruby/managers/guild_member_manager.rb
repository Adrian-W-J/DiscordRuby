module DiscordRuby
  module Managers
    class GuildMemberManager < CachedManager
      attr_reader :guild_id

      def initialize(bot, guild_id)
        super(bot)
        @guild_id = guild_id
      end

      def fetch_all(limit: 1000, after: nil, cache: true)
        data = @bot.api.get_guild_members(@guild_id, limit: limit, after: after)
        members = data.map { |d| Member.new(@bot, d.merge('guild_id' => @guild_id)) }
        members.each { |m| @cache[m.user.id] = m } if cache
        members
      end

      def fetch(user_id, cache: true)
        data = @bot.api.get_guild_member(@guild_id, user_id)
        member = Member.new(@bot, data.merge('guild_id' => @guild_id))
        @cache[user_id] = member if cache
        member
      end

      def search(query, limit: 1, cache: true)
        data = @bot.api.search_guild_members(@guild_id, query: query, limit: limit)
        members = data.map { |d| Member.new(@bot, d.merge('guild_id' => @guild_id)) }
        members.each { |m| @cache[m.user.id] = m } if cache
        members
      end

      def edit(user_id, **options)
        data = @bot.api.modify_guild_member(@guild_id, user_id, **options)
        member = Member.new(@bot, data.merge('guild_id' => @guild_id))
        @cache[user_id] = member
        member
      end

      def kick(user_id, reason: nil)
        @bot.api.remove_guild_member(@guild_id, user_id, reason: reason)
        @cache.delete(user_id)
      end

      def add_role(user_id, role_id, reason: nil)
        @bot.api.add_guild_member_role(@guild_id, user_id, role_id, reason: reason)
      end

      def remove_role(user_id, role_id, reason: nil)
        @bot.api.remove_guild_member_role(@guild_id, user_id, role_id, reason: reason)
      end
    end
  end
end
