module DiscordRuby
  module Managers
    class EmojiManager < CachedManager
      attr_reader :guild_id

      def initialize(bot, guild_id = nil)
        super(bot)
        @guild_id = guild_id
      end

      def fetch_all(cache: true)
        return [] unless @guild_id
        data = @bot.api.get_guild_emojis(@guild_id)
        emojis = data.map { |d| Emoji.new(@bot, d.merge('guild_id' => @guild_id)) }
        emojis.each { |e| @cache[e.id] = e } if cache
        emojis
      end

      def fetch(id, cache: true)
        return nil unless @guild_id
        data = @bot.api.get_guild_emoji(@guild_id, id)
        emoji = Emoji.new(@bot, data.merge('guild_id' => @guild_id))
        @cache[id] = emoji if cache
        emoji
      end

      def create(name:, image:, roles: nil, reason: nil)
        return nil unless @guild_id
        data = @bot.api.create_guild_emoji(@guild_id, name: name, image: image, roles: roles, reason: reason)
        emoji = Emoji.new(@bot, data.merge('guild_id' => @guild_id))
        @cache[emoji.id] = emoji
        emoji
      end

      def edit(id, name: nil, roles: nil, reason: nil)
        return nil unless @guild_id
        data = @bot.api.modify_guild_emoji(@guild_id, id, name: name, roles: roles, reason: reason)
        emoji = Emoji.new(@bot, data.merge('guild_id' => @guild_id))
        @cache[id] = emoji
        emoji
      end

      def delete(id, reason: nil)
        return unless @guild_id
        @bot.api.delete_guild_emoji(@guild_id, id, reason: reason)
        @cache.delete(id)
      end
    end
  end
end
