module DiscordRuby
  module Builders
    class IncidentDataBuilder
      def initialize
        @data = {}
      end

      def invites_disabled_until(time)
        @data[:invites_disabled_until] = time.iso8601
        self
      end

      def dms_disabled_until(time)
        @data[:dms_disabled_until] = time.iso8601
        self
      end

      def to_h
        @data.compact
      end
    end
  end
end
