module DiscordRuby
  module Builders
    class ScheduledEventBuilder
      def initialize
        @data = {
          privacy_level: Constants::PrivacyLevels::GUILD_ONLY
        }
      end

      def name(name)
        @data[:name] = name
        self
      end

      def description(description)
        @data[:description] = description
        self
      end

      def channel_id(channel_id)
        @data[:channel_id] = channel_id
        self
      end

      def scheduled_start_time(time)
        @data[:scheduled_start_time] = time.iso8601
        self
      end

      def scheduled_end_time(time)
        @data[:scheduled_end_time] = time.iso8601
        self
      end

      def entity_type(type)
        @data[:entity_type] = type
        self
      end

      def privacy_level(level)
        @data[:privacy_level] = level
        self
      end

      def location(location)
        @data[:entity_metadata] = { location: location }
        self
      end

      def image(image)
        @data[:image] = image
        self
      end

      def to_h
        @data
      end
    end
  end
end
