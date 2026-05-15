module DiscordRuby
  module Managers
    class AutoModerationManager < CachedManager
      attr_reader :guild_id

      def initialize(bot, guild_id)
        super(bot)
        @guild_id = guild_id
      end

      def fetch_all(cache: true)
        data = @bot.api.get_auto_moderation_rules(@guild_id)
        rules = data.map { |d| AutoModerationRule.new(@bot, d) }
        rules.each { |r| @cache[r.id] = r } if cache
        rules
      end

      def fetch(id, cache: true)
        data = @bot.api.get_auto_moderation_rule(@guild_id, id)
        rule = AutoModerationRule.new(@bot, data)
        @cache[id] = rule if cache
        rule
      end

      def create(**options)
        data = @bot.api.create_auto_moderation_rule(@guild_id, **options)
        rule = AutoModerationRule.new(@bot, data)
        @cache[rule.id] = rule
        rule
      end

      def edit(id, **options)
        data = @bot.api.modify_auto_moderation_rule(@guild_id, id, **options)
        rule = AutoModerationRule.new(@bot, data)
        @cache[id] = rule
        rule
      end

      def delete(id, reason: nil)
        @bot.api.delete_auto_moderation_rule(@guild_id, id, reason: reason)
        @cache.delete(id)
      end
    end
  end
end
