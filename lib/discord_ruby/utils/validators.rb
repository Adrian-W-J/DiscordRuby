module DiscordRuby
  module Utils
    class Validators
      def self.validate_token(token)
        raise ArgumentError, 'Token cannot be nil or empty' if token.nil? || token.empty?
        raise ArgumentError, 'Token must be a string' unless token.is_a?(String)
      end

      def self.validate_snowflake(id)
        raise ArgumentError, "Invalid snowflake: #{id}" unless id.to_s.match?(/\A\d{17,20}\z/)
      end

      def self.validate_channel_type(type)
        raise ArgumentError, "Invalid channel type: #{type}" unless [0, 1, 2, 3, 4, 5, 10, 11, 12, 13, 14, 15, 16].include?(type)
      end

      def self.validate_message_content(content)
        raise ArgumentError, 'Message content must be a string' if content && !content.is_a?(String)
        raise ArgumentError, 'Message content too long' if content && content.length > 2000
      end

      def self.validate_embed_count(embeds)
        raise ArgumentError, 'Too many embeds' if embeds && embeds.length > 10
      end

      def self.validate_component_count(components)
        raise ArgumentError, 'Too many components' if components && components.length > 5
      end

      def self.validate_presence_status(status)
        raise ArgumentError, "Invalid status: #{status}" unless ['online', 'dnd', 'idle', 'invisible', 'offline'].include?(status)
      end
    end
  end
end
