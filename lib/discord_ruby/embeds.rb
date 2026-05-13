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
      if text.to_s.length > 256
        raise ArgumentError, "Embed title cannot exceed 256 characters"
      end
      @title = text
      self
    end

    def set_description(text)
      if text.to_s.length > 4096
        raise ArgumentError, "Embed description cannot exceed 4096 characters"
      end
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

    def set_footer(text:, icon_url: nil, proxy_icon_url: nil)
      if text.to_s.length > 2048
        raise ArgumentError, "Footer text cannot exceed 2048 characters"
      end
      @footer = {text: text, icon_url: icon_url, proxy_icon_url: proxy_icon_url}.compact
      self
    end

    def set_image(url:, proxy_url: nil, height: nil, width: nil)
      @image = {url: url, proxy_url: proxy_url, height: height, width: width}.compact
      self
    end

    def set_thumbnail(url:, proxy_url: nil, height: nil, width: nil)
      @thumbnail = {url: url, proxy_url: proxy_url, height: height, width: width}.compact
      self
    end

    def set_author(name:, url: nil, icon_url: nil, proxy_icon_url: nil)
      if name.to_s.length > 256
        raise ArgumentError, "Author name cannot exceed 256 characters"
      end
      @author = {name: name, url: url, icon_url: icon_url, proxy_icon_url: proxy_icon_url}.compact
      self
    end

    def add_field(name:, value:, inline: false)
      if @fields.size >= 25
        raise ArgumentError, "An embed cannot have more than 25 fields"
      end
      if name.to_s.length > 256
        raise ArgumentError, "Field name cannot exceed 256 characters"
      end
      if value.to_s.length > 1024
        raise ArgumentError, "Field value cannot exceed 1024 characters"
      end
      @fields << {name: name, value: value, inline: inline}
      self
    end

    def self.build
      embed = new
      yield embed if block_given?
      embed
    end

    def total_length
      length = @title.to_s.length + @description.to_s.length + @footer[:text].to_s.length + @author[:name].to_s.length
      length += @fields.sum { |f| f[:name].to_s.length + f[:value].to_s.length }
      length
    end

    def to_h
      if total_length > 6000
        raise ArgumentError, "Total embed length cannot exceed 6000 characters"
      end
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
