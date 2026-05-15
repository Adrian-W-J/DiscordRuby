module DiscordRuby
  module Managers
    class VoiceStateManager < CachedManager
      attr_reader :guild_id

      def initialize(bot, guild_id)
        super(bot)
        @guild_id = guild_id
      end

      def edit_me(channel_id, suppress: nil, request_to_speak_timestamp: nil)
        @bot.api.modify_current_user_voice_state(@guild_id, channel_id: channel_id, suppress: suppress, request_to_speak_timestamp: request_to_speak_timestamp)
      end

      def edit_user(user_id, channel_id, suppress: nil)
        @bot.api.modify_user_voice_state(@guild_id, user_id, channel_id: channel_id, suppress: suppress)
      end
    end
  end
end
