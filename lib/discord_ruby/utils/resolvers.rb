module DiscordRuby
  module Utils
    module Resolvers
      def self.resolve_user(bot, id)
        bot.users.cache[id.to_s] || bot.api.fetch_user(id)
      end

      def self.resolve_member(guild, id)
        guild.members.cache[id.to_s] || guild.bot.api.fetch_guild_member(guild.id, id)
      end

      def self.resolve_channel(bot, id)
        bot.channels.cache[id.to_s] || bot.api.fetch_channel(id)
      end

      def self.resolve_role(guild, id)
        guild.roles.cache[id.to_s] || guild.bot.api.fetch_guild_roles(guild.id).find { |r| r['id'] == id.to_s }
      end

      def self.parse_user_mention(mention)
        match = mention.match(/<@!?(\d+)>/)
        match ? match[1] : nil
      end

      def self.parse_channel_mention(mention)
        match = mention.match(/<#(\d+)>/)
        match ? match[1] : nil
      end

      def self.parse_role_mention(mention)
        match = mention.match(/<@&(\d+)>/)
        match ? match[1] : nil
      end

      def self.parse_emoji(emoji)
        match = emoji.match(/<(a?):(\w+):(\d+)>/)
        match ? {animated: match[1] == 'a', name: match[2], id: match[3]} : nil
      end
    end
  end
end
