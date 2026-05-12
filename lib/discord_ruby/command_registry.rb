module DiscordRuby
  class CommandRegistry
    def initialize
      @commands = {}
    end

    def register(name, &block)
      @commands[name.to_s.downcase] ||= []
      @commands[name.to_s.downcase] << block
    end

    def dispatch(name, event)
      handlers = @commands[name.to_s.downcase]
      return unless handlers
      handlers.each { |handler| handler.call(event) }
    end

    def exists?(name)
      @commands.key?(name.to_s.downcase)
    end
  end
end
