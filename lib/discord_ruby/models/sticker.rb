module DiscordRuby
  class Sticker < BaseModel
    attr_reader :pack_id, :name, :description, :tags, :asset, :type, :format_type, :available, :guild_id, :user, :sort_value

    def guild
      @bot.guilds.cache[@guild_id] if @guild_id
    end

    def pack
      @bot.api.get_sticker_pack(@pack_id) if @pack_id
    end

    def url
      "https://cdn.discordapp.com/stickers/#{id}.png"
    end

    def edit(**options)
      return unless @guild_id
      @bot.api.modify_guild_sticker(@guild_id, id, **options)
    end

    def delete(reason: nil)
      return unless @guild_id
      @bot.api.delete_guild_sticker(@guild_id, id, reason: reason)
    end

    def set_name(name)
      edit(name: name)
    end

    def set_description(description)
      edit(description: description)
    end

    def set_tags(tags)
      edit(tags: tags)
    end

    def ==(other)
      other.is_a?(Sticker) && id == other.id
    end
  end

  class StickerPack < BaseModel
    attr_reader :stickers, :name, :sku_id, :cover_sticker_id, :description, :banner_asset_id

    def initialize(bot, data)
      super
      @stickers = data['stickers']&.map { |s| Sticker.new(bot, s) } || []
    end

    def cover_sticker
      @stickers.find { |s| s.id == @cover_sticker_id }
    end
  end
end
