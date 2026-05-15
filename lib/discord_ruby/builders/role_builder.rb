module DiscordRuby
  module Builders
    class RoleBuilder
      def initialize
        @data = {}
      end

      def name(name)
        @data[:name] = name
        self
      end

      def permissions(permissions)
        @data[:permissions] = permissions.to_i.to_s
        self
      end

      def color(color)
        @data[:color] = color
        self
      end

      def hoist(hoist)
        @data[:hoist] = hoist
        self
      end

      def icon(icon)
        @data[:icon] = icon
        self
      end

      def unicode_emoji(emoji)
        @data[:unicode_emoji] = emoji
        self
      end

      def mentionable(mentionable)
        @data[:mentionable] = mentionable
        self
      end

      def to_h
        @data
      end
    end
  end
end
