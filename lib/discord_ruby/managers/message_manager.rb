module DiscordRuby
  module Managers
    class MessageManager
      attr_reader :channel_id

      def initialize(bot, channel_id)
        @bot = bot
        @channel_id = channel_id
      end

      def fetch(id, force: false, cache: true)
        id = id.to_s
        if !force && @bot.respond_to?(:messages)
          existing = @bot.messages.get(id)
          return existing if existing&.channel_id.to_s == @channel_id.to_s
        end

        remember(@bot.fetch_message(@channel_id, id), cache)
      end

      def fetch_all(cache: true, **options)
        @bot.fetch_channel_messages(@channel_id, **options).map do |data|
          remember(Message.new(@bot, data), cache)
        end
      end

      def create(content = nil, **options)
        remember(@bot.send_message(@channel_id, content, **options))
      end

      def edit(id, **options)
        data = @bot.edit_message(@channel_id, id, **options)
        remember(Message.new(@bot, data))
      end

      def delete(id)
        result = @bot.delete_message(@channel_id, id)
        @bot.messages.delete(id.to_s) if @bot.respond_to?(:messages)
        result
      end

      def fetch_pinned
        @bot.fetch_pinned_messages(@channel_id)
      end

      def pin(id)
        @bot.pin_message(@channel_id, id)
      end

      def unpin(id)
        @bot.unpin_message(@channel_id, id)
      end

      def bulk_delete(ids)
        result = @bot.bulk_delete_messages(@channel_id, ids)
        ids.each { |id| @bot.messages.delete(id.to_s) } if @bot.respond_to?(:messages)
        result
      end

      private

      def remember(message, cache = true)
        @bot.messages.set(message.id, message) if cache && @bot.respond_to?(:messages)
        message
      end
    end
  end
end
