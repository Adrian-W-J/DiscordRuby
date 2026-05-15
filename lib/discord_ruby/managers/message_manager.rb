module DiscordRuby
  module Managers
    class MessageManager < CachedManager
      attr_reader :channel_id

      def initialize(bot, channel_id)
        super(bot)
        @channel_id = channel_id
      end

      def fetch_all(limit: 50, before: nil, after: nil, around: nil, cache: true)
        data = @bot.api.get_channel_messages(@channel_id, limit: limit, before: before, after: after, around: around)
        messages = data.map { |d| Message.new(@bot, d) }
        messages.each { |m| @cache[m.id] = m } if cache
        messages
      end

      def fetch(id, cache: true)
        data = @bot.api.get_channel_message(@channel_id, id)
        message = Message.new(@bot, data)
        @cache[id] = message if cache
        message
      end

      def create(content = nil, **options, &block)
        message = @bot.api.send_message(@channel_id, content, **options, &block)
        @cache[message.id] = message
        message
      end

      def edit(id, content = nil, **options, &block)
        message = @bot.api.edit_message(@channel_id, id, content: content, **options, &block)
        @cache[id] = message
        message
      end

      def delete(id, reason: nil)
        @bot.api.delete_message(@channel_id, id, reason: reason)
        @cache.delete(id)
      end

      def bulk_delete(message_ids, reason: nil)
        @bot.api.bulk_delete_messages(@channel_id, message_ids, reason: reason)
        message_ids.each { |id| @cache.delete(id) }
      end

      def fetch_pinned
        @bot.api.get_pinned_messages(@channel_id).map { |d| Message.new(@bot, d) }
      end

      def pin(id, reason: nil)
        @bot.api.pin_message(@channel_id, id, reason: reason)
      end

      def unpin(id, reason: nil)
        @bot.api.unpin_message(@channel_id, id, reason: reason)
      end
    end
  end
end
