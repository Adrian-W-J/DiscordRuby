module DiscordRuby
  class ShardManager
    attr_reader :shards, :total_shards, :bot

    def initialize(bot, total_shards: nil)
      @bot = bot
      @total_shards = total_shards || fetch_recommended_shards
      @shards = {}
    end

    def fetch_recommended_shards
      response = @bot.api.request(:get, '/gateway/bot')
      response['shards'] || 1
    end

    def spawn_all
      @total_shards.times do |i|
        spawn(i)
      end
    end

    def spawn(shard_id)
      shard = Shard.new(@bot, shard_id, @total_shards)
      @shards[shard_id] = shard
      shard.start
    end

    def stop_all
      @shards.values.each(&:stop)
    end
  end

  class Shard
    attr_reader :id, :total, :gateway

    def initialize(bot, id, total)
      @bot = bot
      @id = id
      @total = total
      @gateway = Gateway.new(bot, shard: [id, total])
    end

    def start
      @gateway.connect
    end

    def stop
      @gateway.disconnect
    end
  end
end
