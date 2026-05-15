module DiscordRuby
  class Presence < BaseModel
    attr_reader :user, :guild_id, :status, :activities, :client_status

    def initialize(bot, data)
      super
      @user = User.new(bot, data['user']) if data['user']
    end

    def guild
      @bot.guilds.cache[@guild_id]
    end

    def member
      guild&.members&.cache&.[](@user.id)
    end

    def online?
      @status == 'online'
    end

    def idle?
      @status == 'idle'
    end

    def dnd?
      @status == 'dnd'
    end

    def offline?
      @status == 'offline' || @status == 'invisible'
    end

    def desktop_status
      @client_status&.[]('desktop')
    end

    def mobile_status
      @client_status&.[]('mobile')
    end

    def web_status
      @client_status&.[]('web')
    end
  end

  class Activity < BaseModel
    attr_reader :name, :type, :url, :created_at, :timestamps, :application_id, :details, :state, :emoji, :party, :assets, :secrets, :instance, :flags, :buttons

    def streaming?
      @type == Constants::ActivityTypes::STREAMING
    end

    def listening?
      @type == Constants::ActivityTypes::LISTENING
    end

    def watching?
      @type == Constants::ActivityTypes::WATCHING
    end

    def competing?
      @type == Constants::ActivityTypes::COMPETING
    end
  end
end
