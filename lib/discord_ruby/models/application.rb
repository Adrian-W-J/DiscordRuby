module DiscordRuby
  class Application < BaseModel
    attr_reader :name, :icon, :description, :rpc_origins, :bot_public, :bot_require_code_grant, :terms_of_service_url, :privacy_policy_url, :owner, :summary, :verify_key, :team, :guild_id, :primary_sku_id, :slug, :cover_image, :flags, :install_params, :custom_install_url, :role_connections_verification_url

    def initialize(bot, data)
      super
      @owner = User.new(bot, data['owner']) if data['owner']
      @team = Team.new(bot, data['team']) if data['team']
    end

    def icon_url(size: 1024, format: 'png')
      return unless @icon
      "https://cdn.discordapp.com/app-icons/#{id}/#{@icon}.#{format}?size=#{size}"
    end

    def cover_image_url(size: 1024, format: 'png')
      return unless @cover_image
      "https://cdn.discordapp.com/app-assets/#{id}/#{@cover_image}.#{format}?size=#{size}"
    end
  end

  class Team < BaseModel
    attr_reader :icon, :members, :name, :owner_user_id

    def initialize(bot, data)
      super
      @members = data['members']&.map { |m| TeamMember.new(bot, m) } || []
    end

    def owner
      @members.find { |m| m.user.id == @owner_user_id }
    end

    def icon_url(size: 1024, format: 'png')
      return unless @icon
      "https://cdn.discordapp.com/team-icons/#{id}/#{@icon}.#{format}?size=#{size}"
    end
  end

  class TeamMember < BaseModel
    attr_reader :membership_state, :permissions, :team_id, :user

    def initialize(bot, data)
      super
      @user = User.new(bot, data['user']) if data['user']
    end
  end
end
