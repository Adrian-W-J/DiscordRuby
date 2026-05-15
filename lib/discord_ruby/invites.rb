module DiscordRuby
  class GuildInviteManager < CachedManager
    attr_reader :guild

    def initialize(guild)
      super(guild.bot, Invite)
      @guild = guild
    end

    def fetch_all
      data = @bot.fetch_guild_invites(@guild.id)
      data.map { |i| add(i) }
    end
  end

  class ChannelInviteManager < CachedManager
    attr_reader :channel

    def initialize(channel)
      super(channel.bot, Invite)
      @channel = channel
    end

    def fetch_all
      data = @bot.fetch_channel_invites(@channel.id)
      data.map { |i| add(i) }
    end

    def create(**options)
      data = @bot.create_channel_invite(@channel.id, **options)
      add(data)
    end
  end
end
