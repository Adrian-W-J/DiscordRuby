require 'digest'
require 'json'

module DiscordRuby
  class RestRateLimits
    Bucket = Struct.new(:mutex, :reset_at)

    def initialize(retries: 3, clock: -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) }, sleeper: ->(delay) { sleep(delay) })
      raise ArgumentError, 'rate_limit_retries must be a nonnegative integer' unless retries.is_a?(Integer) && retries >= 0

      @retries = retries
      @clock = clock
      @sleeper = sleeper
      @mutex = Mutex.new
      @routes = {}
      @buckets = {}
      @global_resets = {}
    end

    def request(method, path, authorization, replayable: true)
      auth = Digest::SHA256.hexdigest(authorization.to_s)
      route, major = route_keys(method, path)
      key = [auth, major, route]
      global_key = auth unless path.start_with?('/interactions/')
      attempt = 0

      loop do
        bucket = @mutex.synchronize { bucket_for(key) }
        response = bucket.mutex.synchronize do
          next unless @mutex.synchronize { bucket_for(key).equal?(bucket) }

          wait(bucket, global_key)
          result = yield attempt
          delay = retry_delay(result) if result.code.to_i == 429
          track(result, key, bucket, global_key, delay)
          return result unless delay && replayable && attempt < @retries

          result
        end
        attempt += 1 if response
      end
    end

    private

    def route_keys(method, path)
      parts = path.split('/')
      major = parts[1, 2] if %w[channels guilds webhooks].include?(parts[1])
      if %w[interactions webhooks].include?(parts[1]) && parts[3] && parts[3] != 'github' && parts[3] != 'slack'
        token_key = Digest::SHA256.hexdigest(parts[3])
        major << token_key if parts[1] == 'webhooks'
        parts[3] = ':token'
      end
      route = parts.map { |part| part.match?(/\A\d+\z/) ? ':id' : part }
      reaction = route.index('reactions')
      route[reaction + 1] = ':emoji' if reaction && route[reaction + 1]
      ["#{method.to_s.upcase} #{route.join('/')}", major]
    end

    def bucket_for(key)
      @routes[key] ||= Bucket.new(Mutex.new, 0)
    end

    def wait(bucket, global_key)
      loop do
        reset_at = @mutex.synchronize { [bucket.reset_at, @global_resets[global_key] || 0].max }
        delay = reset_at - @clock.call
        return unless delay.positive?

        @sleeper.call(delay)
      end
    end

    def retry_delay(response)
      data = JSON.parse(response.body.to_s)
      delay = data['retry_after'] if data.is_a?(Hash)
      seconds(delay) || seconds(response['retry-after'])
    rescue JSON::ParserError
      seconds(response['retry-after'])
    end

    def track(response, key, original, global_key, delay)
      reset_after = seconds(response['x-ratelimit-reset-after'])
      exhausted = response['x-ratelimit-remaining'] == '0'
      global = response['x-ratelimit-global'] == 'true' || response['x-ratelimit-scope'] == 'global'
      bucket_hash = response['x-ratelimit-bucket']

      @mutex.synchronize do
        bucket = if bucket_hash
                   @buckets[[key[0], key[1], bucket_hash]] ||= original
                 else
                   original
                 end
        @routes[key] = bucket
        now = @clock.call
        bucket.reset_at = [bucket.reset_at, now + reset_after].max if exhausted && reset_after
        if delay && global && global_key
          @global_resets[global_key] = [@global_resets[global_key] || 0, now + delay].max
        elsif delay
          bucket.reset_at = [bucket.reset_at, now + delay].max
        end
      end
    end

    def seconds(value)
      delay = Float(value, exception: false)
      delay if delay&.finite? && delay >= 0
    end
  end
end
