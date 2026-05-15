module DiscordRuby
  class Shard
    attr_reader :id, :total, :gateway

    def initialize(id, total, token, intents, gateway_url = nil)
      @id = id
      @total = total
      @gateway = Gateway.new(token: token, intents: intents, gateway_url: gateway_url)
      @gateway.instance_variable_set(:@shard_id, id)
      @gateway.instance_variable_set(:@total_shards, total)

      def @gateway.identify_payload
        payload = super
        payload[:shard] = [@shard_id, @total_shards]
        payload
      end
    end

    def connect
      @gateway.connect
    end

    def disconnect
      @gateway.disconnect
    end

    def run
      @gateway.run
    end

    def on(event, &block)
      @gateway.on(event, &block)
    end

    def uptime
      return 0 unless @gateway.instance_variable_get(:@ready)
      Time.now - @gateway.instance_variable_get(:@ready_at)
    end

    def ping
      @gateway.heartbeat_interval * 1000
    end

    def session_id
      @gateway.session_id
    end

    def sequence
      @gateway.sequence
    end
  end
end
