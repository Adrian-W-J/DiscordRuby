module DiscordRuby
  module Commands
    class Command
      attr_reader :name, :description, :options, :callback, :type, :checks

      def initialize(name, description, options: [], type: 1, payload: nil, &callback)
        @name = name
        @description = description
        @options = options
        @type = type
        @callback = callback
        @payload = payload
        @checks = []
      end

      def add_check(&block)
        @checks << block
        self
      end

      def execute(interaction)
        return unless @checks.all? { |check| check.call(interaction) }
        @callback.call(interaction)
      end

      def to_h
        return @payload.dup if @payload

        {
          name: @name,
          description: @description,
          options: @options.map(&:to_h),
          type: @type
        }
      end
    end

    class CommandOption
      attr_reader :type, :name, :description, :required, :choices, :options, :channel_types, :min_value, :max_value, :min_length, :max_length, :autocomplete

      def initialize(type, name, description, required: false, choices: nil, options: nil, channel_types: nil, min_value: nil, max_value: nil, min_length: nil, max_length: nil, autocomplete: false)
        @type = type
        @name = name
        @description = description
        @required = required
        @choices = choices
        @options = options
        @channel_types = channel_types
        @min_value = min_value
        @max_value = max_value
        @min_length = min_length
        @max_length = max_length
        @autocomplete = autocomplete
      end

      def to_h
        {
          type: @type,
          name: @name,
          description: @description,
          required: @required,
          choices: @choices,
          options: @options&.map(&:to_h),
          channel_types: @channel_types,
          min_value: @min_value,
          max_value: @max_value,
          min_length: @min_length,
          max_length: @max_length,
          autocomplete: @autocomplete
        }.compact
      end
    end

    class CommandRegistry
      def initialize(bot)
        @bot = bot
        @commands = {}
      end

      def register(command)
        @commands[command.name.downcase] = command
      end

      def get(name)
        @commands[name]
      end

      def all
        @commands.values
      end

      def sync_global
        @bot.bulk_overwrite_global_commands(all.map(&:to_h))
      end

      def sync_guild(guild_id)
        @bot.bulk_overwrite_guild_commands(guild_id, all.map(&:to_h))
      end
    end

    class Framework
      def initialize(bot)
        @bot = bot
        @registry = CommandRegistry.new(bot)
      end

      def register_command(name, description, **options, &block)
        register(Command.new(name, description, **options, &block))
      end

      def slash_command(name, description, &block)
        builder = DiscordRuby::Builders::SlashCommandBuilder.new.name(name).description(description)
        proxy = CommandProxy.new(builder)
        yield proxy

        data = builder.to_h
        command = Command.new(data[:name], data[:description], options: data.fetch(:options, []),
                              type: data[:type], payload: data, &proxy.callback)
        proxy.checks.each { |check| command.add_check(&check) }
        register(command)
      end

      def sync_commands(guild_id = nil)
        if guild_id
          @registry.sync_guild(guild_id)
        else
          @registry.sync_global
        end
      end

      private

      def register(command)
        raise ArgumentError, 'a command callback is required' unless command.callback

        name = command.name.downcase
        unless @registry.get(name)
          @bot.on_command(name) { |interaction| @registry.get(name).execute(interaction) }
        end
        @registry.register(command)
        command
      end
    end

    class CommandProxy
      attr_reader :builder, :callback, :checks

      def initialize(builder)
        @builder = builder
        @callback = nil
        @checks = []
      end

      def execute(&block)
        @callback = block
      end

      def check(&block)
        @checks << block
      end

      def method_missing(name, *args, **kwargs, &block)
        @builder.send(name, *args, **kwargs, &block)
      end

      def respond_to_missing?(name, include_private = false)
        @builder.respond_to?(name, include_private) || super
      end
    end
  end

  module Builders
    class SlashCommandBuilder
      def initialize(name = nil, description = nil)
        @name = name
        @description = description
        @options = []
        @type = 1
      end

      def name(val)
        @name = val
        self
      end

      def description(val)
        @description = val
        self
      end

      def type(val)
        @type = val
        self
      end

      def add_option(type, name, description, **opts)
        @options << Commands::CommandOption.new(type, name, description, **opts)
        self
      end

      def string_option(name, description, **opts)
        add_option(3, name, description, **opts)
      end

      def integer_option(name, description, **opts)
        add_option(4, name, description, **opts)
      end

      def boolean_option(name, description, **opts)
        add_option(5, name, description, **opts)
      end

      def user_option(name, description, **opts)
        add_option(6, name, description, **opts)
      end

      def channel_option(name, description, **opts)
        add_option(7, name, description, **opts)
      end

      def role_option(name, description, **opts)
        add_option(8, name, description, **opts)
      end

      def mentionable_option(name, description, **opts)
        add_option(9, name, description, **opts)
      end

      def number_option(name, description, **opts)
        add_option(10, name, description, **opts)
      end

      def attachment_option(name, description, **opts)
        add_option(11, name, description, **opts)
      end

      def sub_command(name, description, &block)
        builder = SlashCommandBuilder.new(name, description)
        block.call(builder) if block
        @options << Commands::CommandOption.new(1, name, description, options: builder.instance_variable_get(:@options))
        self
      end

      def sub_command_group(name, description, &block)
        builder = SlashCommandBuilder.new(name, description)
        block.call(builder) if block
        @options << Commands::CommandOption.new(2, name, description, options: builder.instance_variable_get(:@options))
        self
      end

      def build
        Commands::Command.new(@name, @description, options: @options, type: @type)
      end
    end
  end
end
