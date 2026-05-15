module DiscordRuby
  module Managers
    class GuildManager < CachedManager
      def fetch(id, cache: true, with_counts: false)
        data = @bot.api.get_guild(id, with_counts: with_counts)
        guild = Guild.new(@bot, data)
        @cache[id] = guild if cache
        guild
      end

      def create(name:, **options)
        data = @bot.api.create_guild(name: name, **options)
        guild = Guild.new(@bot, data)
        @cache[guild.id] = guild
        guild
      end

      def edit(id, **options)
        data = @bot.api.modify_guild(id, **options)
        guild = Guild.new(@bot, data)
        @cache[id] = guild
        guild
      end

      def delete(id)
        @bot.api.delete_guild(id)
        @cache.delete(id)
      end

      def leave(id)
        @bot.api.leave_guild(id)
        @cache.delete(id)
      end
    end
  end
end
