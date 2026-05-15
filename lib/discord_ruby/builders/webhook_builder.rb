module DiscordRuby
  module Builders
    class WebhookBuilder
      def initialize
        @data = {}
      end

      def name(name)
        @data[:name] = name
        self
      end

      def avatar(avatar)
        @data[:avatar] = avatar
        self
      end

      def channel_id(id)
        @data[:channel_id] = id
        self
      end

      def to_h
        @data
      end
    end
  end
end
