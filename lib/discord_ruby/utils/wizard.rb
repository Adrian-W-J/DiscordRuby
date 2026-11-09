module DiscordRuby
  class Wizard
    attr_reader :bot, :interaction

    def initialize(bot, interaction)
      @bot = bot
      @interaction = interaction
      @states = {}
      @current_state = nil
      @data = {}
      @timeout = 300
    end

    def self.define(&block)
      Class.new(self) do
        define_method(:configure, &block)
      end
    end

    def state(name, &block)
      @states[name] = State.new(name, &block)
    end

    def start(initial_state)
      configure if respond_to?(:configure)
      @current_state = @states[initial_state]
      run_current_state
    end

    def set_data(key, value)
      @data[key] = value
    end

    def get_data(key)
      @data[key]
    end

    private

    def run_current_state
      return finish if @current_state.nil?


      response_data = @current_state.render(self, @data)

      if @interaction.replied? || @interaction.deferred?
        @interaction.edit_reply(**response_data)
      else
        @interaction.reply(**response_data)
      end


      collector = InteractionCollector.new(@bot, timeout: @timeout, filter: ->(i) {
        i.user.id == @interaction.user.id &&
        (i.message&.id == @interaction.fetch_reply&.id || i.message.nil?)
      })

      collector.on_collect do |i|
        collector.end_collector
        handle_interaction(i)
      end

      collector.on_end do |_, reason|
        handle_timeout if reason == 'timeout'
      end
    end

    def handle_interaction(i)
      @interaction = i
      next_state_name = @current_state.handle(self, i, @data)

      if next_state_name == :finish
        finish
      elsif @states.key?(next_state_name)
        @current_state = @states[next_state_name]
        run_current_state
      else

        run_current_state
      end
    end

    def finish

    end

    def handle_timeout
      @interaction.edit_reply(content: "Wizard timed out.", components: []) rescue nil
    end

    class State
      def initialize(name, &block)
        @name = name
        @render_block = nil
        @handler_block = nil
        instance_eval(&block) if block_given?
      end

      def render(&block)
        @render_block = block
      end

      def on_interaction(&block)
        @handler_block = block
      end

      def run_render(wizard, data)
        @render_block.call(wizard, data)
      end

      def run_handler(wizard, interaction, data)
        @handler_block.call(wizard, interaction, data)
      end


      def render(wizard, data)
        @render_block.call(wizard, data)
      end

      def handle(wizard, interaction, data)
        @handler_block.call(wizard, interaction, data)
      end
    end
  end
end
