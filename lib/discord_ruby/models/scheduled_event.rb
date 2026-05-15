module DiscordRuby
  class ScheduledEvent < BaseModel
    attr_reader :guild_id, :channel_id, :creator_id, :name, :description, :scheduled_start_time, :scheduled_end_time, :privacy_level, :status, :entity_type, :entity_id, :entity_metadata, :creator, :user_count, :image

    def guild
      @bot.guilds.cache[@guild_id]
    end

    def channel
      @bot.channels.cache[@channel_id] if @channel_id
    end

    def edit(**options)
      @bot.api.modify_guild_scheduled_event(@guild_id, id, **options)
    end

    def delete
      @bot.api.delete_guild_scheduled_event(@guild_id, id)
    end

    def fetch_users(limit: 100, with_member: false, before: nil, after: nil)
      @bot.api.get_guild_scheduled_event_users(@guild_id, id, limit: limit, with_member: with_member, before: before, after: after)
    end

    def set_name(name)
      edit(name: name)
    end

    def set_description(description)
      edit(description: description)
    end

    def set_status(status)
      edit(status: status)
    end

    def set_start_time(time)
      edit(scheduled_start_time: time.iso8601)
    end

    def set_end_time(time)
      edit(scheduled_end_time: time.iso8601)
    end

    def set_location(location)
      edit(entity_metadata: { location: location })
    end
  end
end
