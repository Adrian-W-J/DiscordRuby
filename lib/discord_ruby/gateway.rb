require 'websocket-client-simple'
require 'thread'
require 'json'
require 'rbconfig'

module DiscordRuby
  class Gateway
    attr_reader :token, :intents, :sequence, :session_id, :heartbeat_interval, :application_id

    def initialize(token:, intents: 513, gateway_url: nil)
      @token = token
      @intents = intents
      @gateway_url = gateway_url || 'wss://gateway.discord.gg/?v=10&encoding=json'
      @handlers = Hash.new { |hash, key| hash[key] = [] }
      @sequence = nil
      @session_id = nil
      @heartbeat_interval = nil
      @heartbeat_thread = nil
      @socket = nil
      @connected = false
      @mutex = Mutex.new
      @ready = false
      @reconnect_delay = 1
      @last_heartbeat_ack = true
    end

    def on(event, &block)
      @handlers[event.to_s] << block
    end

    def run
      connect
      loop { sleep 1 }
    end

    def connect
      return if @connected

      @socket = WebSocket::Client::Simple.connect(@gateway_url)
      @socket.on :message do |message|
        handle_message(message.data)
      rescue StandardError => error
        dispatch('error', error)
      end

      @socket.on :open do
        @connected = true
        @reconnect_delay = 1
        dispatch('open', nil)
      end

      @socket.on :error do |error|
        dispatch('error', error)
      end

      @socket.on :close do |event|
        @connected = false
        dispatch('close', event)
        stop_heartbeat
        try_reconnect
      end
    end

    def send_payload(op, data)
      return unless @socket && @connected
      payload = {op: op, d: data}
      @socket.send(JSON.generate(payload))
    end

    def handle_message(raw)
      payload = JSON.parse(raw)
      @sequence = payload['s'] if payload.key?('s') && !payload['s'].nil?

      case payload['op']
      when 10
        handle_hello(payload['d'])
      when 11
        @last_heartbeat_ack = true
        dispatch('heartbeat_ack', nil)
      when 0
        handle_dispatch(payload['t'], payload['d'])
      when 7
        restart
      when 9
        handle_invalid_session(payload['d'])
      else
        dispatch('unknown', payload)
      end
    end

    def handle_hello(data)
      @heartbeat_interval = data['heartbeat_interval'] / 1000.0
      start_heartbeat
      if @session_id
        resume
      else
        identify
      end
      dispatch('hello', data)
    end

    def identify
      send_payload(2, identify_payload)
    end

    def resume
      return unless @session_id
      send_payload(6, {
        token: @token,
        session_id: @session_id,
        seq: @sequence
      })
    end

    def handle_dispatch(event_name, data)
      case event_name
      when 'READY'
        @session_id = data['session_id']
        @application_id = data.dig('application', 'id')
        @ready = true
      when 'RESUMED'
        @ready = true
      end

      dispatch(event_name, data)
    end

    def handle_invalid_session(resumable)
      if resumable
        resume
      else
        @session_id = nil
        identify
      end
    end

    def request_guild_members(guild_id, query: '', limit: 0, presences: false, user_ids: nil, nonce: nil)
      payload = {
        guild_id: guild_id,
        query: query,
        limit: limit,
        presences: presences
      }
      payload[:user_ids] = user_ids if user_ids
      payload[:nonce] = nonce if nonce
      send_payload(8, payload)
    end

    def send_presence(status:, activities: [], afk: false, since: nil)
      payload = {
        since: since,
        activities: activities,
        status: status,
        afk: afk
      }
      send_payload(3, payload)
    end

    def start_heartbeat
      stop_heartbeat
      @heartbeat_thread = Thread.new do
        loop do
          sleep(@heartbeat_interval)
          send_payload(1, @sequence)
          @last_heartbeat_ack = false
          dispatch('heartbeat', nil)
          sleep(1)
          unless @last_heartbeat_ack
            dispatch('heartbeat_timeout', nil)
            restart
            break
          end
        end
      end
    end

    def stop_heartbeat
      return unless @heartbeat_thread
      @heartbeat_thread.kill
      @heartbeat_thread = nil
    end

    def restart
      stop_heartbeat
      @socket.close if @socket
      @connected = false
      sleep(@reconnect_delay)
      @reconnect_delay = [@reconnect_delay * 2, 60].min
      connect
    end

    def try_reconnect
      @connected = false
      sleep(@reconnect_delay)
      @reconnect_delay = [@reconnect_delay * 2, 60].min
      connect
    end

    def dispatch(event_name, data)
      @handlers[event_name.to_s].each do |callback|
        Thread.new do
          begin
            callback.call(data)
          rescue StandardError => error
            dispatch('error', error)
          end
        end
      end
    end

    def identify_payload
      {
        token: @token,
        intents: @intents,
        properties: {
          '$os' => RbConfig::CONFIG['host_os'],
          '$browser' => 'discord_ruby',
          '$device' => 'discord_ruby'
        }
      }
    end
  end
end
