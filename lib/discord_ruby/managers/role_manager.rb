module DiscordRuby
  module Managers
    class RoleManager < CachedManager
      attr_reader :guild_id

      def initialize(bot, guild_id)
        super(bot)
        @guild_id = guild_id
      end

      def fetch_all(cache: true)
        data = @bot.api.get_guild_roles(@guild_id)
        roles = data.map { |d| Role.new(@bot, d.merge('guild_id' => @guild_id)) }
        roles.each { |r| @cache[r.id] = r } if cache
        roles
      end

      def create(**options)
        data = @bot.api.create_guild_role(@guild_id, **options)
        role = Role.new(@bot, data.merge('guild_id' => @guild_id))
        @cache[role.id] = role
        role
      end

      def edit(id, **options)
        data = @bot.api.modify_guild_role(@guild_id, id, **options)
        role = Role.new(@bot, data.merge('guild_id' => @guild_id))
        @cache[id] = role
        role
      end

      def delete(id, reason: nil)
        @bot.api.delete_guild_role(@guild_id, id, reason: reason)
        @cache.delete(id)
      end

      def set_positions(positions)
        @bot.api.modify_guild_role_positions(@guild_id, positions)
      end
    end
  end
end
