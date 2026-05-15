module DiscordRuby
  module Builders
    class AutoModerationRuleBuilder
      def initialize
        @data = {
          actions: [],
          enabled: true,
          exempt_roles: [],
          exempt_channels: []
        }
      end

      def name(name)
        @data[:name] = name
        self
      end

      def event_type(type)
        @data[:event_type] = type
        self
      end

      def trigger_type(type)
        @data[:trigger_type] = type
        self
      end

      def trigger_metadata(metadata)
        @data[:trigger_metadata] = metadata
        self
      end

      def add_action(type, metadata = nil)
        action = { type: type }
        action[:metadata] = metadata if metadata
        @data[:actions] << action
        self
      end

      def block_message(custom_message: nil)
        add_action(1, custom_message: custom_message)
      end

      def send_alert_message(channel_id)
        add_action(2, channel_id: channel_id)
      end

      def timeout(duration_seconds)
        add_action(3, timeout_duration_seconds: duration_seconds)
      end

      def enabled(enabled)
        @data[:enabled] = enabled
        self
      end

      def exempt_roles(roles)
        @data[:exempt_roles] = roles
        self
      end

      def exempt_channels(channels)
        @data[:exempt_channels] = channels
        self
      end

      def to_h
        @data
      end
    end
  end
end
