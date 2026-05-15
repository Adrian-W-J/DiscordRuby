module DiscordRuby
  class Emoji < BaseModel
    attr_reader :name, :roles, :user, :require_colons, :managed, :animated, :available, :guild_id

    def guild
      @bot.guilds.cache[@guild_id]
    end

    def author
      @user
    end

    def mention
      "<#{animated ? 'a' : ''}:#{name}:#{id}>"
    end

    def url
      "https://cdn.discordapp.com/emojis/#{id}.#{animated ? 'gif' : 'png'}"
    end

    def edit(**options)
      @bot.api.modify_guild_emoji(@guild_id, id, **options)
    end

    def delete(reason: nil)
      @bot.api.delete_guild_emoji(@guild_id, id, reason: reason)
    end

    def set_name(name)
      edit(name: name)
    end

    def set_roles(roles)
      edit(roles: roles)
    end

    def fetch_author
      data = @bot.api.get_guild_emoji(@guild_id, id)
      @user = User.new(@bot, data['user']) if data['user']
      @user
    end

    def ==(other)
      other.is_a?(Emoji) && id == other.id
    end
  end
end
