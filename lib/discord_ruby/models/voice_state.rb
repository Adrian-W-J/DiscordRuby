module DiscordRuby
  class VoiceState < BaseModel
    attr_reader :guild_id, :channel_id, :user_id, :member, :session_id, :deaf, :mute, :self_deaf, :self_mute, :self_stream, :self_video, :suppress, :request_to_speak_timestamp

    def initialize(bot, data)
      super
      @member = Member.new(bot, data['member'].merge('guild_id' => data['guild_id'])) if data['member'] && data['guild_id']
    end

    def guild
      @bot.guilds.cache[@guild_id]
    end

    def channel
      @bot.channels.cache[@channel_id] if @channel_id
    end

    def user
      @bot.users.cache[@user_id]
    end

    def set_mute(mute, reason: nil)
      @bot.api.modify_guild_member(@guild_id, @user_id, mute: mute, reason: reason)
    end

    def set_deaf(deaf, reason: nil)
      @bot.api.modify_guild_member(@guild_id, @user_id, deaf: deaf, reason: reason)
    end

    def mute(reason: nil)
      set_mute(true, reason: reason)
    end

    def unmute(reason: nil)
      set_mute(false, reason: reason)
    end

    def deafen(reason: nil)
      set_deaf(true, reason: reason)
    end

    def undeafen(reason: nil)
      set_deaf(false, reason: reason)
    end

    def disconnect(reason: nil)
      @bot.api.modify_guild_member(@guild_id, @user_id, channel_id: nil, reason: reason)
    end

    def move(channel_id, reason: nil)
      @bot.api.modify_guild_member(@guild_id, @user_id, channel_id: channel_id, reason: reason)
    end
  end
end
