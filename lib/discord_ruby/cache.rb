module DiscordRuby
  class Cache
    def initialize(limit: 1000, ttl: nil)
      unless limit.nil? || (limit.is_a?(Integer) && limit >= 0)
        raise ArgumentError, 'cache limit must be a nonnegative integer or nil'
      end

      @limit = limit
      unless ttl.nil? || (ttl.is_a?(Numeric) && ttl.finite? && ttl.positive?)
        raise ArgumentError, 'cache ttl must be a positive number of seconds or nil'
      end
      @ttl = ttl
      @store = {}
      @mutex = Mutex.new
    end

    def get(key)
      @mutex.synchronize do
        entry = @store[key]
        if entry && expired?(entry, now)
          @store.delete(key)
          entry = nil
        end
        entry&.first
      end
    end

    def set(key, value)
      return value if @limit == 0

      @mutex.synchronize do
        if @limit && @store.size >= @limit && !@store.key?(key)
          sweep_expired
          prune if @store.size >= @limit
        end
        @store[key] = [value, @ttl && now + @ttl]
        value
      end
    end

    def delete(key)
      @mutex.synchronize { @store.delete(key)&.first }
    end

    def clear
      @mutex.synchronize do
        @store.clear
        {}
      end
    end

    def values
      @mutex.synchronize { sweep_expired; @store.values.map(&:first) }
    end

    def keys
      @mutex.synchronize { sweep_expired; @store.keys }
    end

    def size
      @mutex.synchronize { sweep_expired; @store.size }
    end

    def sweep
      @mutex.synchronize { sweep_expired }
    end

    private

    def now
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def expired?(entry, time)
      entry.last && entry.last <= time
    end

    def sweep_expired
      return 0 unless @ttl

      time = now
      before = @store.size
      @store.delete_if { |_key, entry| expired?(entry, time) }
      before - @store.size
    end

    def prune
      oldest_key = @store.keys.first
      @store.delete(oldest_key)
    end
  end
end
