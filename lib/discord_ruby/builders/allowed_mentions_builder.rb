module DiscordRuby
  module Builders
    class AllowedMentionsBuilder
      def initialize
        @data = {
          parse: []
        }
      end

      def everyone
        @data[:parse] << 'everyone'
        self
      end

      def roles(ids = nil)
        if ids
          @data[:roles] = ids
        else
          @data[:parse] << 'roles'
        end
        self
      end

      def users(ids = nil)
        if ids
          @data[:users] = ids
        else
          @data[:parse] << 'users'
        end
        self
      end

      def replied_user(mention)
        @data[:replied_user] = mention
        self
      end

      def to_h
        @data
      end
    end
  end
end
