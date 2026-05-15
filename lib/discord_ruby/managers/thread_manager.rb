module DiscordRuby
  module Managers
    class ThreadManager < CachedManager
      attr_reader :channel_id

      def initialize(bot, channel_id)
        super(bot)
        @channel_id = channel_id
      end

      def create(name:, auto_archive_duration: 1440, type: 11, reason: nil)
        data = @bot.api.create_thread(@channel_id, name: name, auto_archive_duration: auto_archive_duration, type: type, reason: reason)
        thread = Channel.from_data(@bot, data)
        @cache[thread.id] = thread
        thread
      end

      def create_from_message(message_id, name:, auto_archive_duration: 1440, reason: nil)
        data = @bot.api.create_thread_from_message(@channel_id, message_id, name: name, auto_archive_duration: auto_archive_duration, reason: reason)
        thread = Channel.from_data(@bot, data)
        @cache[thread.id] = thread
        thread
      end

      def fetch_active
        @bot.api.get_active_threads(@bot.guilds.cache.find { |g| g.channels.cache.key?(@channel_id) }&.id || '')
      end

      def fetch_archived_public(before: nil, limit: nil)
        @bot.api.get_public_archived_threads(@channel_id, before: before, limit: limit)
      end

      def fetch_archived_private(before: nil, limit: nil)
        @bot.api.get_private_archived_threads(@channel_id, before: before, limit: limit)
      end

      def fetch_joined_archived_private(before: nil, limit: nil)
        @bot.api.get_joined_private_archived_threads(@channel_id, before: before, limit: limit)
      end
    end
  end
end
