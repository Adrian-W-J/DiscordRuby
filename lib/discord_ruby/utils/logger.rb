module DiscordRuby
  module Utils
    class Logger
      attr_accessor :level

      LEVELS = {
        debug: 0,
        info: 1,
        warn: 2,
        error: 3,
        fatal: 4
      }

      def initialize(level = :info)
        @level = LEVELS[level] || 1
      end

      def debug(msg)
        log(:debug, msg)
      end

      def info(msg)
        log(:info, msg)
      end

      def warn(msg)
        log(:warn, msg)
      end

      def error(msg)
        log(:error, msg)
      end

      def fatal(msg)
        log(:fatal, msg)
      end

      private

      def log(level, msg)
        return if LEVELS[level] < @level
        timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
        puts "[#{timestamp}] [#{level.to_s.upcase}] DiscordRuby: #{msg}"
      end
    end
  end
end
