module DiscordRuby
  class GuildTemplate < BaseModel
    attr_reader :code, :name, :description, :usage_count, :creator_id, :creator, :created_at, :updated_at, :source_guild_id, :serialized_source_guild, :is_dirty

    def initialize(bot, data)
      super
      @creator = User.new(bot, data['creator']) if data['creator']
    end

    def sync
      data = @bot.sync_guild_template(@source_guild_id, @code)
      update_data(data)
      self
    end

    def edit(name: nil, description: nil)
      data = @bot.modify_guild_template(@source_guild_id, @code, name: name, description: description)
      update_data(data)
      self
    end

    def delete
      @bot.delete_guild_template(@source_guild_id, @code)
    end

    def create_guild(name, icon: nil)
      @bot.create_guild_from_template(@code, name, icon: icon)
    end
  end

  class GuildTemplateManager
    attr_reader :guild

    def initialize(guild)
      @guild = guild
      @bot = guild.bot
    end

    def fetch_all
      data = @bot.get_guild_templates(@guild.id)
      data.map { |t| GuildTemplate.new(@bot, t) }
    end

    def create(name:, description: nil)
      data = @bot.create_guild_template(@guild.id, name: name, description: description)
      GuildTemplate.new(@bot, data)
    end
  end
end
