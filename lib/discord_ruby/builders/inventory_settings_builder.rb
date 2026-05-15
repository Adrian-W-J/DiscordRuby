module DiscordRuby
  module Builders
    class InventorySettingsBuilder
      def initialize
        @data = {}
      end

      def is_inventory_button_enabled(enabled)
        @data[:is_inventory_button_enabled] = enabled
        self
      end

      def to_h
        @data.compact
      end
    end
  end
end
