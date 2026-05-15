module DiscordRuby
  module Builders
    class IntegrationBuilder
      def initialize
        @data = {}
      end

      def expire_behavior(val)
        @data[:expire_behavior] = val
        self
      end

      def expire_grace_period(val)
        @data[:expire_grace_period] = val
        self
      end

      def enable_emoticons(val)
        @data[:enable_emoticons] = val
        self
      end

      def to_h
        @data.compact
      end
    end
  end
end
