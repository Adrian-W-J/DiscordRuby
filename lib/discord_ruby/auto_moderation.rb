module DiscordRuby
  module AutoModeration
    module EventType
      MESSAGE_SEND = 1
    end

    module TriggerType
      KEYWORD = 1
      SPAM = 3
      KEYWORD_PRESET = 4
      MENTION_SPAM = 5
    end

    module KeywordPresetType
      PROFANITY = 1
      SEXUALLY_EXPLICIT = 2
      SLURS = 3
    end

    module ActionType
      BLOCK_MESSAGE = 1
      SEND_ALERT_MESSAGE = 2
      TIMEOUT = 3
    end

    class Rule < BaseModel
      attr_reader :guild_id, :name, :creator_id, :event_type, :trigger_type, :trigger_metadata, :actions, :enabled, :exempt_roles, :exempt_channels

      def initialize(bot, data)
        super
        @actions = (data['actions'] || []).map { |a| Action.new(bot, a) }
      end

      def edit(**options)
        data = @bot.modify_auto_moderation_rule(@guild_id, id, **options)
        update_data(data)
        self
      end

      def delete(reason: nil)
        @bot.delete_auto_moderation_rule(@guild_id, id, reason: reason)
      end

      def guild
        @bot.guilds.resolve(@guild_id)
      end
    end

    class Action
      attr_reader :type, :metadata

      def initialize(bot, data)
        @bot = bot
        @type = data['type']
        @metadata = data['metadata']
      end

      def to_h
        { type: @type, metadata: @metadata }.compact
      end
    end
  end

  class GuildAutoModerationManager < CachedManager
    attr_reader :guild

    def initialize(guild)
      super(guild.bot, AutoModeration::Rule)
      @guild = guild
    end

    def fetch_all
      rules = @bot.list_auto_moderation_rules(@guild.id)
      rules.map { |r| add(r) }
    end

    def fetch(id)
      data = @bot.get_auto_moderation_rule(@guild.id, id)
      add(data)
    end

    def create(name:, event_type:, trigger_type:, actions:, trigger_metadata: nil, enabled: true, exempt_roles: nil, exempt_channels: nil, reason: nil)
      data = @bot.create_auto_moderation_rule(
        @guild.id,
        name: name,
        event_type: event_type,
        trigger_type: trigger_type,
        actions: actions.map { |a| a.respond_to?(:to_h) ? a.to_h : a },
        trigger_metadata: trigger_metadata,
        enabled: enabled,
        exempt_roles: exempt_roles,
        exempt_channels: exempt_channels,
        reason: reason
      )
      add(data)
    end
  end
end
