module DiscordRuby
  class Invite < BaseModel
    attr_reader :code, :guild, :channel, :inviter, :target_type, :target_user, :target_application, :approximate_presence_count, :approximate_member_count, :expires_at, :guild_scheduled_event, :uses, :max_uses, :max_age, :temporary, :created_at

    def initialize(bot, data)
      super
      @guild = Guild.new(bot, data['guild']) if data['guild']
      @channel = Channel.new(bot, data['channel']) if data['channel']
      @inviter = User.new(bot, data['inviter']) if data['inviter']
    end

    def delete(reason: nil)
      @bot.api.delete_invite(@code, reason: reason)
    end

    def url
      "https://discord.gg/#{@code}"
    end

    def ==(other)
      other.is_a?(Invite) && code == other.code
    end

    def expired?
      @expires_at && Time.parse(@expires_at) < Time.now
    end

    def guild_id
      @guild&.id || @data['guild_id']
    end

    def channel_id
      @channel&.id || @data['channel_id']
    end
  end
end
