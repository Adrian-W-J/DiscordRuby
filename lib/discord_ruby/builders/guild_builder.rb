module DiscordRuby
  module Builders
    class GuildBuilder
      def initialize
        @data = {}
      end

      def name(name)
        @data[:name] = name
        self
      end

      def region(region)
        @data[:region] = region
        self
      end

      def icon(icon)
        @data[:icon] = icon
        self
      end

      def verification_level(level)
        @data[:verification_level] = level
        self
      end

      def default_message_notifications(level)
        @data[:default_message_notifications] = level
        self
      end

      def explicit_content_filter(level)
        @data[:explicit_content_filter] = level
        self
      end

      def roles(roles)
        @data[:roles] = roles
        self
      end

      def channels(channels)
        @data[:channels] = channels
        self
      end

      def afk_channel_id(id)
        @data[:afk_channel_id] = id
        self
      end

      def afk_timeout(timeout)
        @data[:afk_timeout] = timeout
        self
      end

      def system_channel_id(id)
        @data[:system_channel_id] = id
        self
      end

      def system_channel_flags(flags)
        @data[:system_channel_flags] = flags
        self
      end

      def rules_channel_id(id)
        @data[:rules_channel_id] = id
        self
      end

      def public_updates_channel_id(id)
        @data[:public_updates_channel_id] = id
        self
      end

      def preferred_locale(locale)
        @data[:preferred_locale] = locale
        self
      end

      def features(features)
        @data[:features] = features
        self
      end

      def description(description)
        @data[:description] = description
        self
      end

      def premium_progress_bar_enabled(enabled)
        @data[:premium_progress_bar_enabled] = enabled
        self
      end

      def safety_alerts_channel_id(id)
        @data[:safety_alerts_channel_id] = id
        self
      end

      def to_h
        @data
      end
    end
  end
end
