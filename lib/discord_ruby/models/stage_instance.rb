module DiscordRuby
  class StageInstance < BaseModel
    attr_reader :guild_id, :channel_id, :topic, :privacy_level, :discoverable_disabled, :guild_scheduled_event_id

    def guild
      @bot.guilds.cache[@guild_id]
    end

    def channel
      @bot.channels.cache[@channel_id]
    end

    def edit(**options)
      @bot.api.modify_stage_instance(@channel_id, **options)
    end

    def delete(reason: nil)
      @bot.api.delete_stage_instance(@channel_id, reason: reason)
    end

    def set_topic(topic)
      edit(topic: topic)
    end

    def set_privacy_level(level)
      edit(privacy_level: level)
    end
  end
end
