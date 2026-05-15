module DiscordRuby
  module Builders
    class EmojiBuilder
      def initialize
        @data = {}
      end

      def name(name)
        @data[:name] = name
        self
      end

      def image(image)
        @data[:image] = image
        self
      end

      def roles(roles)
        @data[:roles] = roles
        self
      end

      def to_h
        @data
      end
    end
  end
end
