module DiscordRuby
  module Voice
    class Player
      attr_reader :connection, :current_track, :queue

      def initialize(connection)
        @connection = connection
        @queue = []
        @playing = false
      end

      def play(track)
        @queue << track
        process_queue unless @playing
      end

      def skip
        stop
        process_queue
      end

      def stop
        @playing = false
        @current_track = nil
      end

      def pause
      end

      def resume
      end

      private

      def process_queue
        return if @queue.empty?
        @current_track = @queue.shift
        @playing = true
      end
    end

    class Track
      attr_reader :url, :title, :duration, :requester

      def initialize(url, title: nil, duration: nil, requester: nil)
        @url = url
        @title = title
        @duration = duration
        @requester = requester
      end
    end
  end
end
