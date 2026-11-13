module DiscordRuby
  class ShardGroup
    attr_reader :total_shards, :bots

    def initialize(token:, total_shards: nil, rate_limit_retries: 3, **bot_options)
      limits = RestRateLimits.new(retries: rate_limit_retries)
      @api = APIClient.new(token: token, rest_rate_limits: limits)
      gateway = @api.fetch_gateway_bot
      @total_shards = total_shards || gateway.fetch('shards')
      unless @total_shards.is_a?(Integer) && @total_shards.positive?
        raise ArgumentError, 'total_shards must be a positive integer'
      end

      @session_limit = gateway.fetch('session_start_limit')
      @bot_options = {gateway_url: "#{gateway.fetch('url')}?v=10&encoding=json"}.merge(bot_options)
      @identify_mutex = Mutex.new
      @remaining = @session_limit.fetch('remaining')
      @reset_at = monotonic_time + @session_limit.fetch('reset_after') / 1000.0
      @next_identify = 0
      @bots = Array.new(@total_shards) do |id|
        Bot.new(token: token, **@bot_options, shard: [id, @total_shards], rest_rate_limits: limits,
                before_identify: method(:wait_for_identify))
      end.freeze
    end

    def run!
      finished = Queue.new
      workers = @bots.map do |bot|
        Thread.new do
          bot.run!
          finished << nil
        rescue StandardError => error
          finished << error
        end
      end
      error = finished.pop
      raise error if error
    ensure
      stop!
      workers&.each(&:join)
    end

    def stop!
      @bots.each(&:stop!)
    end

    def bot_for_guild(guild_id)
      @bots.fetch((Integer(guild_id) >> 22) % @total_shards)
    end

    private

    def monotonic_time
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def wait_for_identify(stopping)
      @identify_mutex.synchronize do
        loop do
          return false if stopping.call

          now = monotonic_time
          if now >= @reset_at
            limits = @api.fetch_gateway_bot.fetch('session_start_limit')
            @remaining = limits.fetch('remaining')
            now = monotonic_time
            @reset_at = now + [limits.fetch('reset_after') / 1000.0, 0.25].max
          end
          available_at = @remaining.zero? ? [@reset_at, @next_identify].max : @next_identify
          delay = available_at - now
          if delay <= 0
            @remaining -= 1
            @next_identify = now + 5
            return true
          end

          sleep([delay, 0.25].min)
        end
      end
    end
  end
end
