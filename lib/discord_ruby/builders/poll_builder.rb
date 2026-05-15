module DiscordRuby
  module Builders
    class PollBuilder
      def initialize
        @data = {
          answers: [],
          allow_multiselect: false,
          layout_type: 1
        }
      end

      def question(text)
        @data[:question] = { text: text }
        self
      end

      def add_answer(text, emoji: nil)
        answer = {
          poll_media: {
            text: text
          }
        }
        answer[:poll_media][:emoji] = emoji if emoji
        @data[:answers] << answer
        self
      end

      def allow_multiselect(allow)
        @data[:allow_multiselect] = allow
        self
      end

      def duration(hours)
        @data[:duration] = hours
        self
      end

      def layout_type(type)
        @data[:layout_type] = type
        self
      end

      def to_h
        @data
      end
    end
  end
end
