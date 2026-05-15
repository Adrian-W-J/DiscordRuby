module DiscordRuby
  module Utils
    class Snowflake
      DISCORD_EPOCH = 1420070400000

      attr_reader :id

      def initialize(id)
        @id = id.to_i
      end

      def timestamp
        (@id >> 22) + DISCORD_EPOCH
      end

      def time
        Time.at(timestamp / 1000.0)
      end

      def worker_id
        (@id & 0x3E0000) >> 17
      end

      def process_id
        (@id & 0x1F000) >> 12
      end

      def increment
        @id & 0xFFF
      end

      def self.parse(id)
        new(id)
      end

      def self.generate(time = Time.now)
        ms = (time.to_f * 1000).to_i - DISCORD_EPOCH
        (ms << 22)
      end
    end
  end
end
