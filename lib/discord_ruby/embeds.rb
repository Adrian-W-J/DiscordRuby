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

    def set_title(text)
      @title = text
      self
    end

    def set_description(text)
      @description = text
      self
    end

    def set_url(url)
      @url = url
      self
    end

    def set_timestamp(value = Time.now)
      @timestamp = value.respond_to?(:iso8601) ? value.iso8601 : value
      self
    end

    def set_color(value)
      @color = value
      self
    end

    def footer(text:, icon_url: nil, proxy_icon_url: nil)
      @footer = {text: text, icon_url: icon_url, proxy_icon_url: proxy_icon_url}.compact
      self
    end

    def image(url:, proxy_url: nil, height: nil, width: nil)
      @image = {url: url, proxy_url: proxy_url, height: height, width: width}.compact
      self
    end

    def thumbnail(url:, proxy_url: nil, height: nil, width: nil)
      @thumbnail = {url: url, proxy_url: proxy_url, height: height, width: width}.compact
      self
    end

    def author(name:, url: nil, icon_url: nil, proxy_icon_url: nil)
      @author = {name: name, url: url, icon_url: icon_url, proxy_icon_url: proxy_icon_url}.compact
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
