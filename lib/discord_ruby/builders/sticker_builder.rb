module DiscordRuby
  module Builders
    class StickerBuilder
      def initialize
        @data = {}
      end

      def name(name)
        @data[:name] = name
        self
      end

      def description(description)
        @data[:description] = description
        self
      end

      def tags(tags)
        @data[:tags] = tags
        self
      end

      def file(file)
        @data[:file] = file
        self
      end

      def to_h
        @data
      end
    end
  end
end
