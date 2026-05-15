module DiscordRuby
  module Voice
    class StateManager
      attr_reader :bot, :states

      def initialize(bot)
        @bot = bot
        @states = {}
        setup_listeners
      end

      def setup_listeners
        @bot.on(:voice_state_update) do |event|
          update_state(event.voice_state)
        end
      end

      def update_state(voice_state)
        guild_id = voice_state.guild_id
        @states[guild_id] ||= {}
        @states[guild_id][voice_state.user_id] = voice_state

        if voice_state.channel_id.nil?
          @states[guild_id].delete(voice_state.user_id)
        end
      end

      def get_state(guild_id, user_id)
        @states.dig(guild_id, user_id)
      end

      def get_guild_states(guild_id)
        @states[guild_id] || {}
      end

      def in_channel?(guild_id, user_id, channel_id)
        state = get_state(guild_id, user_id)
        state && state.channel_id == channel_id
      end

      def mute_all(guild_id, channel_id)
        get_guild_states(guild_id).each do |user_id, state|
          if state.channel_id == channel_id
            @bot.api.edit_guild_voice_state(guild_id, user_id, mute: true)
          end
        end
      end

      def unmute_all(guild_id, channel_id)
        get_guild_states(guild_id).each do |user_id, state|
          if state.channel_id == channel_id
            @bot.api.edit_guild_voice_state(guild_id, user_id, mute: false)
          end
        end
      end

      def disconnect_all(guild_id, channel_id)
        get_guild_states(guild_id).each do |user_id, state|
          if state.channel_id == channel_id
            @bot.api.edit_guild_voice_state(guild_id, user_id, channel_id: nil)
          end
        end
      end
    end
  end
end
