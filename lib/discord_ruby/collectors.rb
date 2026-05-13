module DiscordRuby
  class Collector
    def initialize(bot, filter: nil, timeout: nil, max: nil)
      @bot = bot
      @filter = filter
      @timeout = timeout
      @max = max
      @collected = []
      @ended = false
      @timer = nil
    end

    def start
      @timer = Thread.new do
        sleep(@timeout) if @timeout
        end_collector('timeout')
      end if @timeout
      self
    end

    def end_collector(reason = 'user')
      return if @ended
      @ended = true
      @timer.kill if @timer && @timer.alive?
      stop_listening
      @on_end&.call(@collected, reason)
    end

    def on_end(&block)
      @on_end = block
      self
    end

    def on_collect(&block)
      @on_collect = block
      self
    end

    private

    def handle_collect(item)
      return if @ended
      if @filter.nil? || @filter.call(item)
        @collected << item
        @on_collect&.call(item)
        end_collector('limit') if @max && @collected.size >= @max
      end
    end

    def stop_listening
      # To be implemented by subclasses
    end
  end

  class MessageCollector < Collector
    def initialize(bot, channel_id, filter: nil, timeout: nil, max: nil)
      super(bot, filter: filter, timeout: timeout, max: max)
      @channel_id = channel_id
      @handler_id = @bot.on('MESSAGE_CREATE') do |msg|
        handle_collect(msg) if msg['channel_id'] == @channel_id
      end
      start
    end

    def stop_listening
      @bot.off('MESSAGE_CREATE', @handler_id) if @handler_id
    end
  end

  class InteractionCollector < Collector
    def initialize(bot, filter: nil, timeout: nil, max: nil)
      super(bot, filter: filter, timeout: timeout, max: max)
      @handler_id = @bot.on_interaction do |interaction|
        handle_collect(interaction)
      end
      start
    end

    def stop_listening
      @bot.off_interaction(@handler_id) if @handler_id
    end
  end
end
