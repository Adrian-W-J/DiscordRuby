module DiscordRuby
  module Builders
    class ChannelBuilder
      def initialize
        @data = {}
      end

      def name(name)
        @data[:name] = name
        self
      end

      def type(type)
        @data[:type] = type
        self
      end

      def topic(topic)
        @data[:topic] = topic
        self
      end

      def bitrate(bitrate)
        @data[:bitrate] = bitrate
        self
      end

      def user_limit(limit)
        @data[:user_limit] = limit
        self
      end

      def rate_limit_per_user(limit)
        @data[:rate_limit_per_user] = limit
        self
      end

      def position(position)
        @data[:position] = position
        self
      end

      def permission_overwrites(overwrites)
        @data[:permission_overwrites] = overwrites
        self
      end

      def parent_id(id)
        @data[:parent_id] = id
        self
      end

      def nsfw(nsfw)
        @data[:nsfw] = nsfw
        self
      end

      def rtc_region(region)
        @data[:rtc_region] = region
        self
      end

      def video_quality_mode(mode)
        @data[:video_quality_mode] = mode
        self
      end

      def default_auto_archive_duration(duration)
        @data[:default_auto_archive_duration] = duration
        self
      end

      def default_reaction_emoji(emoji)
        @data[:default_reaction_emoji] = emoji
        self
      end

      def available_tags(tags)
        @data[:available_tags] = tags
        self
      end

      def default_sort_order(order)
        @data[:default_sort_order] = order
        self
      end

      def default_forum_layout(layout)
        @data[:default_forum_layout] = layout
        self
      end

      def to_h
        @data
      end
    end
  end
end
