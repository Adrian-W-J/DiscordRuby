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

      def initialize(custom_id:, style:, label: nil, min_length: nil, max_length: nil, required: true, value: nil, placeholder: nil)
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

    class TextDisplay
      TYPE = Interaction::ComponentType::TEXT_DISPLAY

      attr_accessor :content

      def initialize(content)
        @content = content
      end

      def to_h
        {
          type: TYPE,
          content: @content
        }
      end
    end

    class Section
      TYPE = Interaction::ComponentType::SECTION

      attr_accessor :components, :accessory

      def initialize(components: [], accessory: nil)
        @components = components.flatten
        @accessory = accessory
      end

      def add_text(content)
        @components << TextDisplay.new(content)
        self
      end

      def set_accessory(component)
        @accessory = component
        self
      end

      def to_h
        payload = {
          type: TYPE,
          components: @components.map(&:to_h),
          accessory: @accessory&.to_h
        }
        payload.compact
      end
    end

    class Container
      TYPE = Interaction::ComponentType::CONTAINER

      attr_accessor :components, :accent_color, :spoiler

      def initialize(components: [], accent_color: nil, spoiler: false)
        @components = components.flatten
        @accent_color = accent_color
        @spoiler = spoiler
      end

      def add_component(component)
        @components << component
        self
      end

      def self.build(**options)
        container = new(**options)
        yield container if block_given?
        container
      end

      def add_text(content)
        add_component(TextDisplay.new(content))
      end

      def add_row(&block)
        add_component(ActionRow.build(&block))
      end

      def to_h
        payload = {
          type: TYPE,
          components: @components.map(&:to_h),
          accent_color: @accent_color,
          spoiler: @spoiler
        }
        payload.compact
      end
    end

    class Separator
      TYPE = Interaction::ComponentType::SEPARATOR

      def initialize(divider: true, spacing: 1)
        raise ArgumentError, 'separator spacing must be 1 (small) or 2 (large)' unless [1, 2].include?(spacing)

        @divider = divider
        @spacing = spacing
      end

      def to_h
        { type: TYPE, divider: @divider, spacing: @spacing }
      end
    end

    class MediaItem
      attr_accessor :url, :description, :spoiler

      def initialize(url:, description: nil, spoiler: false)
        @url = url
        @description = description
        @spoiler = spoiler
      end

      def to_h
        payload = {
          media: { url: @url },
          description: @description,
          spoiler: @spoiler
        }
        payload.compact
      end
    end

    class Thumbnail
      TYPE = Interaction::ComponentType::THUMBNAIL

      attr_accessor :media_item

      def initialize(url: nil, media_item: nil)
        @media_item = media_item || MediaItem.new(url: url)
      end

      def to_h
        @media_item.to_h.merge(type: TYPE)
      end
    end

    class MediaGallery
      TYPE = Interaction::ComponentType::MEDIA_GALLERY

      attr_accessor :items

      def initialize(items = [])
        @items = items
      end

      def add_item(url:, description: nil, spoiler: false)
        @items << MediaItem.new(url: url, description: description, spoiler: spoiler)
        self
      end

      def to_h
        {
          type: TYPE,
          items: @items.map(&:to_h)
        }
      end
    end

    class File
      TYPE = Interaction::ComponentType::FILE

      attr_accessor :url, :description, :spoiler

      def initialize(url:, description: nil, spoiler: false)
        @url = url
        @description = description
        @spoiler = spoiler
      end

      def to_h
        payload = {
          type: TYPE,
          file: { url: @url },
          spoiler: @spoiler
        }
        payload.compact
      end
    end

    class Label
      TYPE = Interaction::ComponentType::LABEL

      def initialize(label:, component:, description: nil)
        @label = label
        @component = component
        @description = description
      end

      def to_h
        component = @component.to_h.transform_keys(&:to_sym)
        component.delete(:label) if component[:type] == TextInput::TYPE
        component.delete(:disabled) if component[:disabled] == false
        {type: TYPE, label: @label, description: @description, component: component}.compact
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
