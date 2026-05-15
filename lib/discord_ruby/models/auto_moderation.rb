module DiscordRuby
  class AutoModerationRule < BaseModel
    attr_reader :guild_id, :name, :creator_id, :event_type, :trigger_type, :trigger_metadata, :actions, :enabled, :exempt_roles, :exempt_channels

    def guild
      @bot.guilds.cache[@guild_id]
    end

    def creator
      @bot.users.cache[@creator_id]
    end

    def edit(**options)
      @bot.api.modify_auto_moderation_rule(@guild_id, id, **options)
    end

    def delete(reason: nil)
      @bot.api.delete_auto_moderation_rule(@guild_id, id, reason: reason)
    end

    def set_name(name)
      edit(name: name)
    end

    def set_enabled(enabled)
      edit(enabled: enabled)
    end

    def set_actions(actions)
      edit(actions: actions)
    end

    def set_trigger_metadata(metadata)
      edit(trigger_metadata: metadata)
    end

    def set_exempt_roles(roles)
      edit(exempt_roles: roles)
    end

    def set_exempt_channels(channels)
      edit(exempt_channels: channels)
    end
  end

  class AutoModerationAction < BaseModel
    attr_reader :type, :metadata

    def timeout_duration
      @metadata['timeout_duration_seconds'] if @metadata
    end

    def channel_id
      @metadata['channel_id'] if @metadata
    end

    def custom_message
      @metadata['custom_message'] if @metadata
    end
  end
end
