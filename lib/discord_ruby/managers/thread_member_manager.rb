module DiscordRuby
  module Managers
    class ThreadMemberManager < CachedManager
      attr_reader :thread_id

      def initialize(bot, thread_id)
        super(bot)
        @thread_id = thread_id
      end

      def add(user_id = '@me')
        @bot.api.add_thread_member(@thread_id, user_id)
      end

      def remove(user_id = '@me')
        @bot.api.remove_thread_member(@thread_id, user_id)
      end

      def fetch_all(with_member: false, after: nil, limit: nil)
        @bot.api.get_thread_members(@thread_id, with_member: with_member, after: after, limit: limit)
      end

      def fetch(user_id, with_member: false)
        @bot.api.get_thread_member(@thread_id, user_id, with_member: with_member)
      end
    end
  end
end
