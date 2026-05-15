module DiscordRuby
  class ApplicationCommand < BaseModel
    attr_reader :application_id, :guild_id, :name, :name_localizations, :description, :description_localizations, :options, :default_member_permissions, :dm_permission, :default_permission, :nsfw, :version, :type

    def edit(**options)
      data = @bot.edit_application_command(@application_id, id, guild_id: @guild_id, **options)
      update_data(data)
      self
    end

    def delete
      @bot.delete_application_command(@application_id, id, guild_id: @guild_id)
    end
  end

  class ApplicationCommandManager < CachedManager
    attr_reader :application_id, :guild_id

    def initialize(bot, application_id, guild_id: nil)
      super(bot, ApplicationCommand)
      @application_id = application_id
      @guild_id = guild_id
    end

    def fetch_all
      data = @bot.get_application_commands(@application_id, guild_id: @guild_id)
      data.map { |c| add(c) }
    end

    def fetch(id)
      data = @bot.get_application_command(@application_id, id, guild_id: @guild_id)
      add(data)
    end

    def create(data)
      res = @bot.create_application_command(@application_id, data, guild_id: @guild_id)
      add(res)
    end

    def bulk_overwrite(commands)
      data = @bot.bulk_overwrite_application_commands(@application_id, commands, guild_id: @guild_id)
      data.map { |c| add(c) }
    end
  end
end
