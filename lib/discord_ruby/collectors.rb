require 'monitor'

module DiscordRuby
  class Collector
    def initialize(bot, filter: nil, timeout: nil, idle: nil, max: nil)
      [timeout, idle].compact.each do |duration|
        unless duration.is_a?(Numeric) && duration.finite? && duration >= 0
          raise ArgumentError, 'collector durations must be nonnegative seconds'
        end
      end
      raise ArgumentError, 'max must be a positive integer' if max && !(max.is_a?(Integer) && max.positive?)

      @bot = bot
      @filter = filter
      @timeout = timeout
      @idle = idle
      @max = max
      @collected = []
      @reason = nil
      @lock = Monitor.new
      @changed = @lock.new_cond
      @callbacks = {collect: [], end: []}
    end

    def start
      @lock.synchronize do
        return self if @started || @reason

        @started = true
        reset_timer
        @timer = Thread.new { wait_for_expiry } if @timeout || @idle
      end
      self
    end

    def reset_timer
      @lock.synchronize do
        now = monotonic_time
        @deadline = now + @timeout if @timeout
        @idle_deadline = now + @idle if @idle
        @changed.broadcast
      end
      self
    end

    def end_collector(reason = 'user')
      @lock.synchronize do
        return if @reason

        @reason = reason
        @changed.broadcast
        stop_listening
        @callbacks[:end].each { |callback| callback.call(@collected.dup, reason) }
        @callbacks.each_value(&:clear)
      end
    end

    def ended?
      @lock.synchronize { !@reason.nil? }
    end

    def collected
      @lock.synchronize { @collected.dup }
    end

    def on_end(&block)
      @lock.synchronize do
        if @reason
          block.call(@collected.dup, @reason)
        else
          @callbacks[:end] << block
        end
      end
      self
    end

    def on_collect(&block)
      @lock.synchronize { @callbacks[:collect] << block unless @reason }
      self
    end

    private

    def monotonic_time
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def wait_for_expiry
      @lock.synchronize do
        until @reason
          deadline, reason = [[@deadline, 'timeout'], [@idle_deadline, 'idle']]
                             .select { |time, _reason| time }.min_by(&:first)
          delay = deadline - monotonic_time
          if delay <= 0
            end_collector(reason)
          else
            @changed.wait(delay)
          end
        end
      end
    end

    def handle_collect(item)
      @lock.synchronize do
        return if @reason || (@filter && !@filter.call(item))

        @collected << item
        @idle_deadline = monotonic_time + @idle if @idle
        @changed.broadcast
        begin
          @callbacks[:collect].dup.each { |callback| callback.call(item) }
        ensure
          end_collector('limit') if @max && @collected.size >= @max
        end
      end
    end

    def stop_listening; end
  end

  class MessageCollector < Collector
    def initialize(bot, channel_id, **options)
      super(bot, **options)
      @handler_id = @bot.on('MESSAGE_CREATE') do |message|
        handle_collect(message) if message['channel_id'].to_s == channel_id.to_s
      end
      start
    end

    def stop_listening
      @bot.off('MESSAGE_CREATE', @handler_id) if @handler_id
    end
  end

  class InteractionCollector < Collector
    def initialize(bot, channel_id: nil, message_id: nil, custom_id: nil, user_id: nil, **options)
      super(bot, **options)
      @handler_id = @bot.on_interaction do |interaction|
        next if channel_id && interaction.channel_id.to_s != channel_id.to_s
        next if message_id && (!interaction.respond_to?(:message) || interaction.message&.id.to_s != message_id.to_s)
        next if custom_id && (!interaction.respond_to?(:custom_id) || interaction.custom_id != custom_id)
        next if user_id && interaction.user&.id.to_s != user_id.to_s

        handle_collect(interaction)
      end
      start
    end

    def stop_listening
      @bot.off_interaction(@handler_id) if @handler_id
    end
  end

  class ReactionCollector < Collector
    def initialize(bot, message_id, channel_id: nil, **options)
      super(bot, **options)
      @handler_id = @bot.on('MESSAGE_REACTION_ADD') do |reaction|
        next unless reaction['message_id'].to_s == message_id.to_s
        next if channel_id && reaction['channel_id'].to_s != channel_id.to_s

        handle_collect(reaction)
      end
      start
    end

    def stop_listening
      @bot.off('MESSAGE_REACTION_ADD', @handler_id) if @handler_id
    end
  end
end
