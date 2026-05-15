module DiscordRuby
  class SoundboardSound < BaseModel
    attr_reader :name, :sound_id, :volume, :emoji_id, :emoji_name, :guild_id, :available, :user

    def initialize(bot, data)
      super
      @user = User.new(bot, data['user']) if data['user']
    end

    def delete
      @bot.delete_guild_soundboard_sound(@guild_id, id)
    end

    def edit(**options)
      data = @bot.modify_guild_soundboard_sound(@guild_id, id, **options)
      update_data(data)
      self
    end
  end

  class GuildSoundboardManager < CachedManager
    attr_reader :guild

    def initialize(guild)
      super(guild.bot, SoundboardSound)
      @guild = guild
    end

    def fetch_all
      sounds = @bot.list_guild_soundboard_sounds(@guild.id)
      sounds.map { |s| add(s) }
    end

    def create(name:, sound:, emoji_id: nil, emoji_name: nil, volume: nil)
      data = @bot.create_guild_soundboard_sound(@guild.id, name: name, sound: sound, emoji_id: emoji_id, emoji_name: emoji_name, volume: volume)
      add(data)
    end
  end
end
