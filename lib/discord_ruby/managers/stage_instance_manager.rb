module DiscordRuby
  module Managers
    class StageInstanceManager < CachedManager
      attr_reader :guild_id

      def initialize(bot, guild_id)
        super(bot)
        @guild_id = guild_id
      end

      def fetch(channel_id, cache: true)
        data = @bot.api.get_stage_instance(channel_id)
        instance = StageInstance.new(@bot, data)
        @cache[channel_id] = instance if cache
        instance
      end

      def create(channel_id, topic:, privacy_level: 2, send_start_notification: false)
        data = @bot.api.create_stage_instance(channel_id, topic: topic, privacy_level: privacy_level, send_start_notification: send_start_notification)
        instance = StageInstance.new(@bot, data)
        @cache[channel_id] = instance
        instance
      end

      def edit(channel_id, topic: nil, privacy_level: nil)
        data = @bot.api.modify_stage_instance(channel_id, topic: topic, privacy_level: privacy_level)
        instance = StageInstance.new(@bot, data)
        @cache[channel_id] = instance
        instance
      end

      def delete(channel_id, reason: nil)
        @bot.api.delete_stage_instance(channel_id, reason: reason)
        @cache.delete(channel_id)
      end
    end
  end
end
