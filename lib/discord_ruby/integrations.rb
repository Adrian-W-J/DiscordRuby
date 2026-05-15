module DiscordRuby
  class Integration < BaseModel
    attr_reader :name, :type, :enabled, :syncing, :role_id, :enable_emoticons, :expire_behavior, :expire_grace_period, :user, :account, :synced_at, :subscriber_count, :revoked, :application, :guild_id

    def initialize(bot, data)
      super
      @user = User.new(bot, data['user']) if data['user']
      @account = data['account']
      @application = data['application']
    end

    def delete
      @bot.delete_guild_integration(@guild_id, id)
    end
  end

  class GuildIntegrationManager
    attr_reader :guild

    def initialize(guild)
      @guild = guild
      @bot = guild.bot
    end

    def fetch_all
      data = @bot.get_guild_integrations(@guild.id)
      data.map { |i| Integration.new(@bot, i.merge('guild_id' => @guild.id)) }
    end

    def delete(integration_id)
      @bot.delete_guild_integration(@guild.id, integration_id)
    end
  end
end
