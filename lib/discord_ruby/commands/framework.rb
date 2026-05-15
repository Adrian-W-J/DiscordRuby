module DiscordRuby
  module Commands
    class Command
      attr_reader :name, :description, :options, :callback, :type

      def initialize(name, description, options: [], type: 1, &callback)
        @name = name
        @description = description
        @options = options
        @type = type
        @callback = callback
      end

      def execute(interaction)
        @callback.call(interaction)
      end

      def to_h
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
        @commands[command.name] = command
      end

      def get(name)
        @commands[name]
      end

      def all
        @commands.values
      end

      def sync_global
        @bot.api.bulk_overwrite_global_application_commands(@bot.application_id, all.map(&:to_h))
      end

      def sync_guild(guild_id)
        @bot.api.bulk_overwrite_guild_application_commands(@bot.application_id, guild_id, all.map(&:to_h))
      end
    end

    class Framework
      def initialize(bot)
        @bot = bot
        @registry = CommandRegistry.new(bot)
        setup_listeners
      end

      def register_command(name, description, **options, &block)
        command = Command.new(name, description, **options, &block)
        @registry.register(command)
      end

      def setup_listeners
        @bot.on(:interaction_create) do |interaction|
          next unless interaction.is_a?(DiscordRuby::CommandInteraction)

          command = @registry.get(interaction.command_name)
          if command
            begin
              command.execute(interaction)
            rescue => e
              warn "Error executing command #{command.name}: #{e.message}"
              puts e.backtrace
            end
          end
        end
      end

      def sync_commands(guild_id = nil)
        if guild_id
          @registry.sync_guild(guild_id)
        else
          @registry.sync_global
        end
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
