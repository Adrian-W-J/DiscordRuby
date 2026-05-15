module DiscordRuby
  class Role < BaseModel
    attr_reader :name, :color, :hoist, :icon, :unicode_emoji, :position, :permissions, :managed, :mentionable, :tags, :guild_id

    def initialize(bot, data)
      super
      @permissions = Permissions.new(data['permissions']) if data['permissions']
    end

    def guild
      @bot.guilds.cache[@guild_id]
    end

    def mention
      "<@&#{id}>"
    end

    def edit(**options)
      @bot.api.modify_guild_role(@guild_id, id, **options)
    end

    def delete(reason: nil)
      @bot.api.delete_guild_role(@guild_id, id, reason: reason)
    end

    def set_name(name)
      edit(name: name)
    end

    def set_color(color)
      edit(color: color)
    end

    def set_hoist(hoist)
      edit(hoist: hoist)
    end

    def set_position(position)
      edit(position: position)
    end

    def set_permissions(permissions)
      edit(permissions: permissions.to_i)
    end

    def set_mentionable(mentionable)
      edit(mentionable: mentionable)
    end

    def compare_positions(other)
      return 0 if id == other.id
      position <=> other.position
    end

    def ==(other)
      other.is_a?(Role) && id == other.id
    end

    def permissions_in(channel)
      @bot.utils.permissions_calculator.calculate_permissions(self, channel)
    end
  end
end
