module DiscordRuby
  class Attachment < BaseModel
    attr_reader :filename, :description, :content_type, :size, :url, :proxy_url, :height, :width, :ephemeral, :duration_secs, :waveform

    def image?
      ['image/jpeg', 'image/png', 'image/gif', 'image/webp'].include?(@content_type)
    end

    def video?
      ['video/mp4', 'video/quicktime', 'video/webm'].include?(@content_type)
    end

    def audio?
      ['audio/mpeg', 'audio/ogg', 'audio/wav', 'audio/flac'].include?(@content_type)
    end

    def spoiler?
      @filename&.start_with?('SPOILER_')
    end

    def size_kb
      @size / 1024.0
    end

    def size_mb
      @size / 1048576.0
    end

    def download
      require 'open-uri'
      URI.open(@url).read
    end

    def ==(other)
      other.is_a?(Attachment) && id == other.id
    end
  end
end
