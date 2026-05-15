module DiscordRuby
  class GuildStickerManager < CachedManager
    attr_reader :guild

    def initialize(guild)
      super(guild.bot, Sticker)
      @guild = guild
    end

    def fetch_all
      data = @bot.fetch_guild_stickers(@guild.id)
      data.map { |s| add(s) }
    end

    def fetch(id)
      data = @bot.fetch_guild_sticker(@guild.id, id)
      add(data)
    end

    def create(name:, description:, tags:, file:, **options)
      data = @bot.create_guild_sticker(@guild.id, name: name, description: description, tags: tags, file: file, **options)
      add(data)
    end
  end
end
