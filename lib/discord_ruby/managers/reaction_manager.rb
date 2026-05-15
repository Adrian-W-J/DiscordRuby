module DiscordRuby
  module Managers
    class ReactionManager < BaseManager
      attr_reader :channel_id, :message_id

      def initialize(bot, channel_id, message_id)
        super(bot)
        @channel_id = channel_id
        @message_id = message_id
      end

      def fetch_all(emoji, limit: 100, after: nil)
        emoji_str = emoji.is_a?(Emoji) ? "#{emoji.name}:#{emoji.id}" : emoji
        @bot.api.get_reactions(@channel_id, @message_id, emoji_str, limit: limit, after: after).map { |d| User.new(@bot, d) }
      end

      def create(emoji)
        emoji_str = emoji.is_a?(Emoji) ? "#{emoji.name}:#{emoji.id}" : emoji
        @bot.api.create_reaction(@channel_id, @message_id, emoji_str)
      end

      def delete_own(emoji)
        emoji_str = emoji.is_a?(Emoji) ? "#{emoji.name}:#{emoji.id}" : emoji
        @bot.api.delete_own_reaction(@channel_id, @message_id, emoji_str)
      end

      def delete_user(emoji, user_id)
        emoji_str = emoji.is_a?(Emoji) ? "#{emoji.name}:#{emoji.id}" : emoji
        @bot.api.delete_user_reaction(@channel_id, @message_id, emoji_str, user_id)
      end

      def delete_all(emoji = nil)
        if emoji
          emoji_str = emoji.is_a?(Emoji) ? "#{emoji.name}:#{emoji.id}" : emoji
          @bot.api.delete_all_reactions_for_emoji(@channel_id, @message_id, emoji_str)
        else
          @bot.api.delete_all_reactions(@channel_id, @message_id)
        end
      end
    end
  end
end
