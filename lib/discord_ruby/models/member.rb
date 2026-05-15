module DiscordRuby
  class Member < BaseModel
    attr_reader :user, :nick, :avatar, :roles, :joined_at, :premium_since, :deaf, :mute, :flags, :pending, :permissions, :communication_disabled_until, :guild_id

    def initialize(bot, data)
      super
      @user = User.new(bot, data['user']) if data['user']
      @roles = data['roles'] || []
    end

    def id
      @user&.id || (@data[:id] || @data['id']).to_s
    end

    def mention
      @nick ? "<@!#{id}>" : "<@#{id}>"
    end

    def timeout(until_time, reason: nil)
      @bot.api.modify_guild_member(@guild_id, id, communication_disabled_until: until_time.iso8601, reason: reason)
    end

    def set_nickname(nick, reason: nil)
      @bot.api.modify_guild_member(@guild_id, id, nick: nick, reason: reason)
    end

    def add_role(role_id, reason: nil)
      @bot.api.add_guild_member_role(@guild_id, id, role_id, reason: reason)
    end

    def remove_role(role_id, reason: nil)
      @bot.api.remove_guild_member_role(@guild_id, id, role_id, reason: reason)
    end

    def kick(reason: nil)
      @bot.api.remove_guild_member(@guild_id, id, reason: reason)
    end

    def ban(delete_message_days: 0, reason: nil)
      @bot.api.create_guild_ban(@guild_id, id, delete_message_days: delete_message_days, reason: reason)
    end

    def avatar_url(size: 1024, format: nil)
      return nil unless @avatar
      format ||= @avatar.start_with?('a_') ? 'gif' : 'png'
      "https://cdn.discordapp.com/guilds/#{@guild_id}/users/#{id}/avatars/#{@avatar}.#{format}?size=#{size}"
    end

    def display_avatar_url(size: 1024, format: nil)
      avatar_url(size: size, format: format) || @user&.avatar_url(size: size, format: format) || @user&.default_avatar_url
    end

    def permissions
      return @permissions if @permissions
      guild = @bot.guilds.cache[@guild_id]
      return nil unless guild

      if id == guild.owner_id
        @permissions = Permissions.new(Permissions::FLAGS[:administrator])
      else
        base_perms = guild.roles.find { |r| r.id == @guild_id }&.permissions&.to_i || 0
        member_roles = guild.roles.select { |r| @roles.include?(r.id) }
        member_roles.each { |r| base_perms |= r.permissions.to_i }
        @permissions = Permissions.new(base_perms)
      end
    end

    def guild
      @bot.guilds.cache[@guild_id]
    end

    def voice
      guild&.voice_states&.cache&.[](id)
    end

    def display_name
      @nick || @user&.global_name || @user&.username
    end

    def manageable?
      return false if id == guild&.owner_id
      return false if id == @bot.user.id
      return true if @bot.user.id == guild&.owner_id

      me = guild&.me
      return false unless me

      me.highest_role.compare_positions(highest_role) > 0
    end

    def bannable?
      manageable? && me.permissions.has?(:ban_members)
    end

    def kickable?
      manageable? && me.permissions.has?(:kick_members)
    end

    def highest_role
      guild&.roles&.select { |r| @roles.include?(r.id) }&.max_by(&:position) || guild&.roles&.find { |r| r.id == @guild_id }
    end

    def timed_out?
      @communication_disabled_until && Time.parse(@communication_disabled_until) > Time.now
    end

    def remove_timeout(reason: nil)
      timeout(nil, reason: reason)
    end

    def ==(other)
      other.is_a?(Member) && id == other.id && @guild_id == other.guild_id
    end
  end
end
