module DiscordRuby
  module Utils
    module Helpers
      def self.format_bytes(size)
        units = %w[B KB MB GB TB]
        return '0 B' if size == 0
        i = (Math.log(size) / Math.log(1024)).floor
        "#{sprintf('%.2f', size.to_f / 1024**i)} #{units[i]}"
      end

      def self.format_duration(seconds)
        days = seconds / 86400
        hours = (seconds % 86400) / 3600
        minutes = (seconds % 3600) / 60
        secs = seconds % 60

        parts = []
        parts << "#{days}d" if days > 0
        parts << "#{hours}h" if hours > 0
        parts << "#{minutes}m" if minutes > 0
        parts << "#{secs}s" if secs > 0 || parts.empty?
        parts.join(' ')
      end

      def self.to_hex(color)
        return color if color.is_a?(Integer)
        return color.to_i(16) if color.is_a?(String) && color.match?(/\A#?[0-9a-fA-F]{6}\z/)
        0
      end

      def self.camelize(str)
        str.split('_').map(&:capitalize).join
      end

      def self.underscore(str)
        str.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
           .gsub(/([a-z\d])([A-Z])/, '\1_\2')
           .tr('-', '_')
           .downcase
      end

      def self.deep_merge(hash1, hash2)
        hash1.merge(hash2) do |_, old_val, new_val|
          if old_val.is_a?(Hash) && new_val.is_a?(Hash)
            deep_merge(old_val, new_val)
          else
            new_val
          end
        end
      end
    end
  end
end
