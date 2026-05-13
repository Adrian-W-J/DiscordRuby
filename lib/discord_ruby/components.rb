module DiscordRuby
  module Component
    class ActionRow
      TYPE = Interaction::ComponentType::ACTION_ROW
      MAX_WIDTH = 5

      attr_reader :components

      def initialize(*components)
        @components = components.flatten
      end

      def self.build
        row = new
        yield row if block_given?
        row
      end

      def width
        @components.sum do |c|
          case c.class.name.split('::').last
          when 'Button' then 1
          when 'StringSelectMenu', 'UserSelectMenu', 'RoleSelectMenu', 'MentionableSelectMenu', 'ChannelSelectMenu', 'SelectMenu' then 5
          when 'TextInput' then 5
          else 0
          end
        end
      end

      def add_component(component)
        current_width = width
        component_width = case component.class.name.split('::').last
                          when 'Button' then 1
                          when 'StringSelectMenu', 'UserSelectMenu', 'RoleSelectMenu', 'MentionableSelectMenu', 'ChannelSelectMenu', 'SelectMenu' then 5
                          when 'TextInput' then 5
                          else 0
                          end

        if current_width + component_width > MAX_WIDTH
          raise ArgumentError, "ActionRow width exceeded: current #{current_width} + new #{component_width} > #{MAX_WIDTH}"
        end

        @components << component
        self
      end

    def add_button(label: nil, custom_id: nil, style: Interaction::ButtonStyle::PRIMARY, url: nil, emoji: nil, disabled: false)
      add_component(Button.new(label: label, custom_id: custom_id, style: style, url: url, emoji: emoji, disabled: disabled))
    end

    def add_string_select(custom_id:, options: [], placeholder: nil, min_values: 1, max_values: 1, disabled: false)
      add_component(StringSelectMenu.new(custom_id: custom_id, options: options, placeholder: placeholder, min_values: min_values, max_values: max_values, disabled: disabled))
    end

    def add_user_select(custom_id:, placeholder: nil, min_values: 1, max_values: 1, disabled: false)
      add_component(UserSelectMenu.new(custom_id: custom_id, placeholder: placeholder, min_values: min_values, max_values: max_values, disabled: disabled))
    end

    def add_role_select(custom_id:, placeholder: nil, min_values: 1, max_values: 1, disabled: false)
      add_component(RoleSelectMenu.new(custom_id: custom_id, placeholder: placeholder, min_values: min_values, max_values: max_values, disabled: disabled))
    end

    def add_mentionable_select(custom_id:, placeholder: nil, min_values: 1, max_values: 1, disabled: false)
      add_component(MentionableSelectMenu.new(custom_id: custom_id, placeholder: placeholder, min_values: min_values, max_values: max_values, disabled: disabled))
    end

    def add_channel_select(custom_id:, channel_types: nil, placeholder: nil, min_values: 1, max_values: 1, disabled: false)
      add_component(ChannelSelectMenu.new(custom_id: custom_id, channel_types: channel_types, placeholder: placeholder, min_values: min_values, max_values: max_values, disabled: disabled))
    end

    def add_text_input(custom_id:, label:, style: Interaction::TextInputStyle::SHORT, min_length: nil, max_length: nil, required: true, value: nil, placeholder: nil)
      add_component(TextInput.new(custom_id: custom_id, label: label, style: style, min_length: min_length, max_length: max_length, required: required, value: value, placeholder: placeholder))
    end

      def to_h
        {
          type: TYPE,
          components: @components.map(&:to_h)
        }
      end
    end

    class Button
      TYPE = Interaction::ComponentType::BUTTON

      attr_accessor :style, :label, :custom_id, :url, :disabled, :emoji

      def initialize(style:, label: nil, custom_id: nil, url: nil, disabled: false, emoji: nil)
        @style = style
        @label = label
        @custom_id = custom_id
        @url = url
        @disabled = disabled
        @emoji = emoji
      end

      def to_h
        payload = {
          type: TYPE,
          style: @style,
          label: @label,
          custom_id: @custom_id,
          url: @url,
          disabled: @disabled,
          emoji: @emoji
        }
        payload.compact
      end
    end

    class SelectOption
      attr_accessor :label, :value, :description, :emoji, :default

      def initialize(label:, value:, description: nil, emoji: nil, default: false)
        @label = label
        @value = value
        @description = description
        @emoji = emoji
        @default = default
      end

      def to_h
        payload = {
          label: @label,
          value: @value,
          description: @description,
          emoji: @emoji,
          default: @default
        }
        payload.compact
      end
    end

    class SelectMenu
      attr_accessor :type, :custom_id, :options, :placeholder, :min_values, :max_values, :disabled

      def initialize(type: Interaction::ComponentType::STRING_SELECT, custom_id:, options: [], placeholder: nil, min_values: 1, max_values: 1, disabled: false)
        @type = type
        @custom_id = custom_id
        @options = options.dup
        @placeholder = placeholder
        @min_values = min_values
        @max_values = max_values
        @disabled = disabled
      end

      def add_option(option)
        @options << option
        self
      end

      def to_h
        payload = {
          type: @type,
          custom_id: @custom_id,
          options: @options.empty? ? nil : @options.map(&:to_h),
          placeholder: @placeholder,
          min_values: @min_values,
          max_values: @max_values,
          disabled: @disabled
        }
        payload.compact
      end
    end

    class StringSelectMenu < SelectMenu
      def initialize(custom_id:, options: [], placeholder: nil, min_values: 1, max_values: 1, disabled: false)
        super(type: Interaction::ComponentType::STRING_SELECT, custom_id: custom_id, options: options, placeholder: placeholder, min_values: min_values, max_values: max_values, disabled: disabled)
      end
    end

    class UserSelectMenu < SelectMenu
      def initialize(custom_id:, placeholder: nil, min_values: 1, max_values: 1, disabled: false)
        super(type: Interaction::ComponentType::USER_SELECT, custom_id: custom_id, placeholder: placeholder, min_values: min_values, max_values: max_values, disabled: disabled)
      end
    end

    class RoleSelectMenu < SelectMenu
      def initialize(custom_id:, placeholder: nil, min_values: 1, max_values: 1, disabled: false)
        super(type: Interaction::ComponentType::ROLE_SELECT, custom_id: custom_id, placeholder: placeholder, min_values: min_values, max_values: max_values, disabled: disabled)
      end
    end

    class MentionableSelectMenu < SelectMenu
      def initialize(custom_id:, placeholder: nil, min_values: 1, max_values: 1, disabled: false)
        super(type: Interaction::ComponentType::MENTIONABLE_SELECT, custom_id: custom_id, placeholder: placeholder, min_values: min_values, max_values: max_values, disabled: disabled)
      end
    end

    class ChannelSelectMenu < SelectMenu
      attr_accessor :channel_types

      def initialize(custom_id:, channel_types: nil, placeholder: nil, min_values: 1, max_values: 1, disabled: false)
        super(type: Interaction::ComponentType::CHANNEL_SELECT, custom_id: custom_id, placeholder: placeholder, min_values: min_values, max_values: max_values, disabled: disabled)
        @channel_types = channel_types
      end

      def to_h
        super.merge(channel_types: @channel_types).compact
      end
    end

    class TextInput
      TYPE = Interaction::ComponentType::TEXT_INPUT

      attr_accessor :custom_id, :style, :label, :min_length, :max_length, :required, :value, :placeholder

      def initialize(custom_id:, style:, label:, min_length: nil, max_length: nil, required: true, value: nil, placeholder: nil)
        @custom_id = custom_id
        @style = style
        @label = label
        @min_length = min_length
        @max_length = max_length
        @required = required
        @value = value
        @placeholder = placeholder
      end

      def to_h
        payload = {
          type: TYPE,
          custom_id: @custom_id,
          style: @style,
          label: @label,
          min_length: @min_length,
          max_length: @max_length,
          required: @required,
          value: @value,
          placeholder: @placeholder
        }
        payload.compact
      end
    end

    class Modal
      attr_accessor :title, :custom_id, :components

      def initialize(title:, custom_id:, components: [])
        @title = title
        @custom_id = custom_id
        @components = components.flatten
      end

      def add_component(component)
        @components << component
        self
      end

      def to_h
        {
          title: @title,
          custom_id: @custom_id,
          components: @components.map(&:to_h)
        }
      end
    end
  end
end
