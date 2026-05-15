module DiscordRuby
  module Builders
    class WidgetBuilder
      def initialize
        @data = {}
      end

      def enabled(val)
        @data[:enabled] = val
        self
      end

      def channel_id(val)
        @data[:channel_id] = val
        self
      end

      def to_h
        @data.compact
      end
    end
  end
end
