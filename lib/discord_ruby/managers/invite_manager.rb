module DiscordRuby
  module Managers
    class InviteManager < BaseManager
      attr_reader :guild_id, :channel_id

      def initialize(bot, guild_id: nil, channel_id: nil)
        super(bot)
        @guild_id = guild_id
        @channel_id = channel_id
      end

      def fetch_all
        if @channel_id
          @bot.api.get_channel_invites(@channel_id).map { |d| Invite.new(@bot, d) }
        elsif @guild_id
          @bot.api.get_guild_invites(@guild_id).map { |d| Invite.new(@bot, d) }
        else
          []
        end
      end

      def fetch(code, with_counts: false, with_expiration: false, guild_scheduled_event_id: nil)
        data = @bot.api.get_invite(code, with_counts: with_counts, with_expiration: with_expiration, guild_scheduled_event_id: guild_scheduled_event_id)
        Invite.new(@bot, data)
      end

      def create(options = {})
        return nil unless @channel_id
        data = @bot.api.create_channel_invite(@channel_id, **options)
        Invite.new(@bot, data)
      end

      def delete(code, reason: nil)
        @bot.api.delete_invite(code, reason: reason)
      end
    end
  end
end
