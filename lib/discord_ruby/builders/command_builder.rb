module DiscordRuby
  module Builders
    class SlashCommandBuilder
      def initialize
        @data = {
          type: Constants::ApplicationCommandTypes::CHAT_INPUT,
          options: []
        }
      end

      def name(name)
        @data[:name] = name
        self
      end

      def description(description)
        @data[:description] = description
        self
      end

      def name_localizations(localizations)
        @data[:name_localizations] = localizations
        self
      end

      def description_localizations(localizations)
        @data[:description_localizations] = localizations
        self
      end

      def add_name_localization(locale, name)
        @data[:name_localizations] ||= {}
        @data[:name_localizations][locale] = name
        self
      end

      def add_description_localization(locale, description)
        @data[:description_localizations] ||= {}
        @data[:description_localizations][locale] = description
        self
      end

      def type(type)
        @data[:type] = type
        self
      end

      def add_option(name:, description:, type:, required: false, choices: nil, options: nil, channel_types: nil, min_value: nil, max_value: nil, min_length: nil, max_length: nil, autocomplete: false, name_localizations: nil, description_localizations: nil)
        option = {
          name: name,
          description: description,
          type: type,
          required: required,
          autocomplete: autocomplete
        }
        option[:choices] = choices if choices
        option[:options] = options if options
        option[:channel_types] = channel_types if channel_types
        option[:min_value] = min_value if min_value
        option[:max_value] = max_value if max_value
        option[:min_length] = min_length if min_length
        option[:max_length] = max_length if max_length
        option[:name_localizations] = name_localizations if name_localizations
        option[:description_localizations] = description_localizations if description_localizations

        @data[:options] << option
        self
      end

      def string_option(name:, description:, **opts)
        add_option(name: name, description: description, type: Constants::ApplicationCommandOptionTypes::STRING, **opts)
      end

      def integer_option(name:, description:, **opts)
        add_option(name: name, description: description, type: Constants::ApplicationCommandOptionTypes::INTEGER, **opts)
      end

      def boolean_option(name:, description:, **opts)
        add_option(name: name, description: description, type: Constants::ApplicationCommandOptionTypes::BOOLEAN, **opts)
      end

      def user_option(name:, description:, **opts)
        add_option(name: name, description: description, type: Constants::ApplicationCommandOptionTypes::USER, **opts)
      end

      def channel_option(name:, description:, **opts)
        add_option(name: name, description: description, type: Constants::ApplicationCommandOptionTypes::CHANNEL, **opts)
      end

      def role_option(name:, description:, **opts)
        add_option(name: name, description: description, type: Constants::ApplicationCommandOptionTypes::ROLE, **opts)
      end

      def mentionable_option(name:, description:, **opts)
        add_option(name: name, description: description, type: Constants::ApplicationCommandOptionTypes::MENTIONABLE, **opts)
      end

      def number_option(name:, description:, **opts)
        add_option(name: name, description: description, type: Constants::ApplicationCommandOptionTypes::NUMBER, **opts)
      end

      def attachment_option(name:, description:, **opts)
        add_option(name: name, description: description, type: Constants::ApplicationCommandOptionTypes::ATTACHMENT, **opts)
      end

      def sub_command(name:, description:, &block)
        builder = SubCommandBuilder.new(name, description)
        yield builder if block_given?
        @data[:options] << builder.to_h
        self
      end

      def sub_command_group(name:, description:, &block)
        builder = SubCommandGroupBuilder.new(name, description)
        yield builder if block_given?
        @data[:options] << builder.to_h
        self
      end

      def dm_permission(enabled)
        @data[:dm_permission] = enabled
        self
      end

      def integration_types(*types)
        @data[:integration_types] = types.flatten
        self
      end

      def contexts(*contexts)
        @data[:contexts] = contexts.flatten
        self
      end

      def default_member_permissions(permissions)
        @data[:default_member_permissions] = permissions.to_i.to_s
        self
      end

      def nsfw(enabled)
        @data[:nsfw] = enabled
        self
      end

      def to_h
        if [Constants::ApplicationCommandTypes::USER, Constants::ApplicationCommandTypes::MESSAGE].include?(@data[:type])
          @data.except(:description, :description_localizations, :options)
        else
          @data
        end
      end
    end

    class SubCommandBuilder < SlashCommandBuilder
      def initialize(name, description)
        @data = {
          name: name,
          description: description,
          type: Constants::ApplicationCommandOptionTypes::SUB_COMMAND,
          options: []
        }
      end
    end

    class SubCommandGroupBuilder < SlashCommandBuilder
      def initialize(name, description)
        @data = {
          name: name,
          description: description,
          type: Constants::ApplicationCommandOptionTypes::SUB_COMMAND_GROUP,
          options: []
        }
      end

      def sub_command(name:, description:, &block)
        builder = SubCommandBuilder.new(name, description)
        yield builder if block_given?
        @data[:options] << builder.to_h
        self
      end
    end
  end
end
