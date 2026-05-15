module DiscordRuby
  module Managers
    class UserManager < CachedManager
      def fetch(id, cache: true)
        data = @bot.api.get_user(id)
        user = User.new(@bot, data)
        @cache[id] = user if cache
        user
      end

      def modify_current_user(**options)
        data = @bot.api.modify_current_user(**options)
        @bot.instance_variable_set(:@user, User.new(@bot, data))
      end
    end
  end

  module Builders
    class UserBuilder
      def initialize
        @data = {}
      end

      def username(val)
        @data[:username] = val
        self
      end

      def avatar(val)
        @data[:avatar] = val
        self
      end

      def banner(val)
        @data[:banner] = val
        self
      end

      def accent_color(val)
        @data[:accent_color] = val
        self
      end

      def to_h
        @data.compact
      end
    end
  end
end
