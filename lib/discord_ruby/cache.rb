module DiscordRuby
  class Cache
    def initialize(limit: 1000)
      @limit = limit
      @store = {}
    end

    def get(key)
      @store[key]
    end

    def set(key, value)
      prune if @store.size >= @limit
      @store[key] = value
    end

    def delete(key)
      @store.delete(key)
    end

    def clear
      @store.clear
    end

    def values
      @store.values
    end

    def keys
      @store.keys
    end

    private

    def prune
      oldest_key = @store.keys.first
      @store.delete(oldest_key)
    end
  end
end
