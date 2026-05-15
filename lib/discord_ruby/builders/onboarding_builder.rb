module DiscordRuby
  module Managers
    class OnboardingManager < BaseManager
      attr_reader :guild_id

      def initialize(bot, guild_id)
        super(bot)
        @guild_id = guild_id
      end

      def fetch
        @bot.api.get_guild_onboarding(@guild_id)
      end

      def edit(**options)
        @bot.api.modify_guild_onboarding(@guild_id, **options)
      end
    end
  end

  module Builders
    class OnboardingBuilder
      def initialize
        @data = {
          prompts: [],
          default_channel_ids: [],
          enabled: true,
          mode: 0
        }
      end

      def add_prompt(title:, options:, type: 0, single_select: true, required: true, id: nil)
        prompt = {
          title: title,
          options: options,
          type: type,
          single_select: single_select,
          required: required
        }
        prompt[:id] = id if id
        @data[:prompts] << prompt
        self
      end

      def default_channel_ids(ids)
        @data[:default_channel_ids] = ids
        self
      end

      def enabled(enabled)
        @data[:enabled] = enabled
        self
      end

      def mode(mode)
        @data[:mode] = mode
        self
      end

      def to_h
        @data.compact
      end
    end
  end
end
