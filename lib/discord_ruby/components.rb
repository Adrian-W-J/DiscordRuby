module DiscordRuby
  module Component
    class ActionRow
      TYPE = Interaction::ComponentType::ACTION_ROW

      attr_reader :components

      def initialize(*components)
        @components = components.flatten
      end

      def add_component(component)
        @components << component
        self
      end

      def add_button(**options)
        add_component(Button.new(**options))
      end

      def add_select(**options)
        add_component(SelectMenu.new(**options))
      end

      def add_text_input(**options)
        add_component(TextInput.new(**options))
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
      TYPE = Interaction::ComponentType::STRING_SELECT

      attr_accessor :custom_id, :options, :placeholder, :min_values, :max_values, :disabled

      def initialize(custom_id:, options: [], placeholder: nil, min_values: 1, max_values: 1, disabled: false)
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
          type: TYPE,
          custom_id: @custom_id,
          options: @options.map(&:to_h),
          placeholder: @placeholder,
          min_values: @min_values,
          max_values: @max_values,
          disabled: @disabled
        }
        payload.compact
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
