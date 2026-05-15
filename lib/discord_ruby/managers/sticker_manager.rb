module DiscordRuby
  module Managers
    class StickerManager < CachedManager
      attr_reader :guild_id

      def initialize(bot, guild_id = nil)
        super(bot)
        @guild_id = guild_id
      end

      def fetch_all(cache: true)
        return [] unless @guild_id
        data = @bot.api.get_guild_stickers(@guild_id)
        stickers = data.map { |d| Sticker.new(@bot, d) }
        stickers.each { |s| @cache[s.id] = s } if cache
        stickers
      end

      def fetch(id, cache: true)
        if @guild_id
          data = @bot.api.get_guild_sticker(@guild_id, id)
          sticker = Sticker.new(@bot, data)
        else
          data = @bot.api.get_sticker(id)
          sticker = Sticker.new(@bot, data)
        end
        @cache[id] = sticker if cache
        sticker
      end

      def create(name:, description:, tags:, file:, reason: nil)
        return nil unless @guild_id
        data = @bot.api.create_guild_sticker(@guild_id, name: name, description: description, tags: tags, file: file, reason: reason)
        sticker = Sticker.new(@bot, data)
        @cache[sticker.id] = sticker
        sticker
      end

      def edit(id, **options)
        return nil unless @guild_id
        data = @bot.api.modify_guild_sticker(@guild_id, id, **options)
        sticker = Sticker.new(@bot, data)
        @cache[id] = sticker
        sticker
      end

      def delete(id, reason: nil)
        return unless @guild_id
        @bot.api.delete_guild_sticker(@guild_id, id, reason: reason)
        @cache.delete(id)
      end

      def fetch_nitro_packs
        @bot.api.get_sticker_packs['sticker_packs'].map { |d| StickerPack.new(@bot, d) }
      end
    end
  end
end
