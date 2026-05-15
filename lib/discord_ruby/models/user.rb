module DiscordRuby
  class User < BaseModel
    attr_reader :username, :discriminator, :avatar, :bot_user, :system, :mfa_enabled, :banner, :accent_color, :locale, :verified, :email, :flags, :premium_type, :public_flags, :avatar_decoration, :global_name, :display_name

    def initialize(bot, data)
      super
      @username = data['username']
      @discriminator = data['discriminator']
      @avatar = data['avatar']
      @bot_user = data['bot']
      @system = data['system']
      @mfa_enabled = data['mfa_enabled']
      @banner = data['banner']
      @accent_color = data['accent_color']
      @locale = data['locale']
      @verified = data['verified']
      @email = data['email']
      @flags = data['flags']
      @premium_type = data['premium_type']
      @public_flags = data['public_flags']
      @avatar_decoration = data['avatar_decoration']
      @global_name = data['global_name']
      @display_name = data['display_name']
    end

    def tag
      @discriminator == '0' ? @username : "#{@username}##{@discriminator}"
    end

    def mention
      "<@#{id}>"
    end

    def avatar_url(size: 1024, format: nil)
      return nil unless @avatar
      format ||= @avatar.start_with?('a_') ? 'gif' : 'png'
      "https://cdn.discordapp.com/avatars/#{id}/#{@avatar}.#{format}?size=#{size}"
    end

    def default_avatar_url
      index = @discriminator == '0' ? (id.to_i >> 22) % 6 : @discriminator.to_i % 5
      "https://cdn.discordapp.com/embed/avatars/#{index}.png"
    end

    def display_avatar_url(size: 1024, format: nil)
      avatar_url(size: size, format: format) || default_avatar_url
    end

    def banner_url(size: 1024, format: 'png')
      return nil unless @banner
      "https://cdn.discordapp.com/banners/#{id}/#{@banner}.#{format}?size=#{size}"
    end

    def bot?
      !!@bot_user
    end

    def system?
      !!@system
    end

    def fetch
      data = @bot.api.fetch_user(id)
      update_data(data)
      self
    end

    def create_dm
      data = @bot.api.create_dm_channel(id)
      Channel.from_data(@bot, data)
    end

    def send_message(content, **options)
      channel = create_dm
      channel.send_message(content, **options)
    end

    alias_method :send_dm, :send_message

    def hex_accent_color
      return nil unless @accent_color
      "#{@accent_color.to_s(16).rjust(6, '0')}"
    end

    def public_flags_bitfield
      Bitfield.new(@public_flags || 0)
    end

    def fetch_flags
      @flags_bitfield ||= UserFlags.new(@flags || 0)
    end

    def fetch_public_flags
      @public_flags_bitfield ||= UserFlags.new(@public_flags || 0)
    end

    def premium_type_name
      case @premium_type
      when 0 then 'None'
      when 1 then 'Nitro Classic'
      when 2 then 'Nitro'
      when 3 then 'Nitro Basic'
      else 'Unknown'
      end
    end

    def dm_channel
      @dm_channel ||= create_dm
    end

    def ==(other)
      other.is_a?(User) && id == other.id
    end
  end
end
