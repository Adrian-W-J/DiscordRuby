require 'websocket-client-simple'
require 'thread'
require 'json'
require 'rbconfig'
require 'securerandom'

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
      handler_id = SecureRandom.uuid
      @handlers[event.to_s] << { id: handler_id, block: block }
      handler_id
    end

    def off(event, handler_id)
      @handlers[event.to_s].reject! { |h| h[:id] == handler_id }
    end

    def run
      connect
      @running = true
      while @running
        sleep 1
      end
    end

    def connect
      return if @connected

      puts "[DEBUG] Connecting to #{@gateway_url}..." if ENV['DEBUG']
      gateway = self
      @socket = WebSocket::Client::Simple.connect(@gateway_url)
      @socket.on :message do |message|
        gateway.handle_message(message.data)
      rescue StandardError => error
        gateway.dispatch('error', error)
      end

      @socket.on :open do
        puts "[DEBUG] WebSocket connection opened" if ENV['DEBUG']
        gateway.instance_variable_set(:@connected, true)
        gateway.instance_variable_set(:@reconnect_delay, 1)
        gateway.dispatch('open', nil)
      end

      @socket.on :error do |error|
        gateway.dispatch('error', error)
      end

      @socket.on :close do |event|
        puts "[DEBUG] WebSocket connection closed: #{event.inspect}" if ENV['DEBUG']
        gateway.instance_variable_set(:@connected, false)
        gateway.dispatch('close', event)
        gateway.stop_heartbeat
        gateway.try_reconnect
      end
    end

    def send_payload(op, data)
      return unless @socket && @connected
      payload = {op: op, d: data}
      @socket.send(JSON.generate(payload))
    end

    def handle_message(raw)
      begin
        payload = JSON.parse(raw)
      rescue JSON::ParserError => e
        message = raw.strip
        if message == "Authentication failed."
          specific_error = "Authentication failed. Your token is likely invalid or has been reset."
        else
          specific_error = "Invalid gateway response (not JSON): #{message[0..100]}..."
        end
        warn "[ERROR] #{specific_error}"
        dispatch('error', StandardError.new(specific_error))
        return
      end

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
      puts "[DEBUG] Hello received. Heartbeat interval: #{@heartbeat_interval}s" if ENV['DEBUG']
      start_heartbeat
      if @session_id
        puts "[DEBUG] Resuming session: #{@session_id}" if ENV['DEBUG']
        resume
      else
        puts "[DEBUG] Identifying..." if ENV['DEBUG']
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
      if ENV['DEBUG']
        if event_name == 'MESSAGE_CREATE'
          puts "[DEBUG] Handling dispatch: MESSAGE_CREATE - Content: #{data['content']}"
        else
          puts "[DEBUG] Handling dispatch: #{event_name}"
        end
      end
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

        sleep(@heartbeat_interval * rand)
        loop do
          send_payload(1, @sequence)
          @last_heartbeat_ack = false
          dispatch('heartbeat', nil)


          sleep(@heartbeat_interval)

          unless @last_heartbeat_ack
            puts "[GATEWAY] Heartbeat ACK not received, reconnecting..." if ENV['DEBUG']
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

    def disconnect
      @running = false
      @socket.close if @socket
      @connected = false
      stop_heartbeat
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
      puts "[DEBUG] Dispatching event: #{event_name}" if ENV['DEBUG']
      @handlers[event_name.to_s].each do |handler|
        Thread.new do
          begin
            handler[:block].call(data)
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
