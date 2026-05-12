module DiscordRuby
  class Embed
    attr_accessor :title, :description, :url, :timestamp, :color, :footer, :image, :thumbnail, :author, :fields

    def initialize(title: nil, description: nil, url: nil, timestamp: nil, color: nil)
      @title = title
      @description = description
      @url = url
      @timestamp = timestamp
      @color = color
      @footer = {}
      @image = {}
      @thumbnail = {}
      @author = {}
      @fields = []
    end

    def footer(text:, icon_url: nil)
      @footer = {text: text, icon_url: icon_url}.compact
      self
    end

    def image(url:)
      @image = {url: url}
      self
    end

    def thumbnail(url:)
      @thumbnail = {url: url}
      self
    end

    def author(name:, url: nil, icon_url: nil)
      @author = {name: name, url: url, icon_url: icon_url}.compact
      self
    end

    def add_field(name:, value:, inline: false)
      @fields << {name: name, value: value, inline: inline}
      self
    end

    def to_h
      {
        title: @title,
        description: @description,
        url: @url,
        timestamp: @timestamp,
        color: @color,
        footer: @footer.empty? ? nil : @footer,
        image: @image.empty? ? nil : @image,
        thumbnail: @thumbnail.empty? ? nil : @thumbnail,
        author: @author.empty? ? nil : @author,
        fields: @fields.empty? ? nil : @fields
      }.compact
    end
  end
end
