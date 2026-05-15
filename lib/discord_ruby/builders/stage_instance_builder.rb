module DiscordRuby
  module Builders
    class StageInstanceBuilder
      def initialize
        @data = {
          privacy_level: Constants::PrivacyLevels::GUILD_ONLY
        }
      end

      def topic(topic)
        @data[:topic] = topic
        self
      end

      def channel_id(channel_id)
        @data[:channel_id] = channel_id
        self
      end

      def privacy_level(level)
        @data[:privacy_level] = level
        self
      end

      def send_start_notification(notify)
        @data[:send_start_notification] = notify
        self
      end

      def guild_scheduled_event_id(id)
        @data[:guild_scheduled_event_id] = id
        self
      end

      def to_h
        @data
      end
    end
  end
end
