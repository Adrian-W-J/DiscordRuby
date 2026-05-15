module DiscordRuby
  class VoiceRegion < BaseModel
    attr_reader :name, :optimal, :deprecated, :custom

    def id
      @data['id']
    end
  end

  class VoiceStateManager < CachedManager
    attr_reader :guild

    def initialize(guild)
      super(guild.bot, VoiceState)
      @guild = guild
    end

    def fetch_for_user(user_id)
      resolve(user_id)
    end
  end

  module Voice
    class Connection
      attr_reader :bot, :channel_id, :guild_id

      def initialize(bot, guild_id, channel_id)
        @bot = bot
        @guild_id = guild_id
        @channel_id = channel_id
      end

      def disconnect
        @bot.gateway.send_voice_state_update(@guild_id, nil)
      end

      def set_mute(mute)
        @bot.gateway.send_voice_state_update(@guild_id, @channel_id, self_mute: mute)
      end

      def set_deaf(deaf)
        @bot.gateway.send_voice_state_update(@guild_id, @channel_id, self_deaf: deaf)
      end
    end
  end
end
