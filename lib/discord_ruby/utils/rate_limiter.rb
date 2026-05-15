module DiscordRuby
  module Utils
    class RateLimiter
      def initialize
        @mutex = Mutex.new
        @buckets = {}
      end

      def wait_for(bucket_id)
        bucket = @mutex.synchronize { @buckets[bucket_id] ||= Bucket.new }
        bucket.wait
      end

      def update(bucket_id, limit, remaining, reset_after)
        bucket = @mutex.synchronize { @buckets[bucket_id] ||= Bucket.new }
        bucket.update(limit, remaining, reset_after)
      end

      class Bucket
        def initialize
          @mutex = Mutex.new
          @limit = nil
          @remaining = nil
          @reset_after = nil
          @reset_time = nil
        end

        def wait
          @mutex.synchronize do
            if @remaining && @remaining <= 0
              sleep_time = @reset_time - Time.now
              if sleep_time > 0
                puts "[DEBUG] Rate limit reached, waiting #{sleep_time}s" if ENV['DEBUG']
                sleep(sleep_time)
              end
            end
          end
        end

        def update(limit, remaining, reset_after)
          @mutex.synchronize do
            @limit = limit
            @remaining = remaining
            @reset_after = reset_after
            @reset_time = Time.now + reset_after
          end
        end
      end
    end
  end
end
