module DiscordRuby
  module Utils
    class PermissionsCalculator
      def self.calculate_base_permissions(guild, member)
        return Constants::Permissions::ADMINISTRATOR if member.id == guild.owner_id

        permissions = guild.roles.find { |r| r.id == guild.id }&.permissions&.bits || 0

        member.roles.each do |role_id|
          role = guild.roles.find { |r| r.id == role_id }
          permissions |= role.permissions.bits if role
        end

        return Constants::Permissions::ADMINISTRATOR if (permissions & Constants::Permissions::ADMINISTRATOR) != 0

        permissions
      end

      def self.calculate_overwrites(base_permissions, guild, member, channel)
        return Constants::Permissions::ADMINISTRATOR if (base_permissions & Constants::Permissions::ADMINISTRATOR) != 0

        permissions = base_permissions

        everyone_overwrite = channel.permission_overwrites.find { |o| o['id'] == guild.id }
        if everyone_overwrite
          permissions &= ~everyone_overwrite['deny'].to_i
          permissions |= everyone_overwrite['allow'].to_i
        end

        allow = 0
        deny = 0
        member.roles.each do |role_id|
          role_overwrite = channel.permission_overwrites.find { |o| o['id'] == role_id }
          if role_overwrite
            allow |= role_overwrite['allow'].to_i
            deny |= role_overwrite['deny'].to_i
          end
        end
        permissions &= ~deny
        permissions |= allow

        member_overwrite = channel.permission_overwrites.find { |o| o['id'] == member.id }
        if member_overwrite
          permissions &= ~member_overwrite['deny'].to_i
          permissions |= member_overwrite['allow'].to_i
        end

        permissions
      end

      def self.calculate_permissions(guild, member, channel = nil)
        base = calculate_base_permissions(guild, member)
        return base unless channel
        calculate_overwrites(base, guild, member, channel)
      end
    end
  end
end
