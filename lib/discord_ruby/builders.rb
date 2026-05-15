module DiscordRuby
  module Builders
    class EmbedBuilder
      def initialize
        @data = { embeds: [] }
      end

      def self.build
        builder = new
        yield builder if block_given?
        builder.to_h
      end

      def add_embed
        embed = Embed.new
        yield embed if block_given?
        @data[:embeds] << embed.to_h
        self
      end

      def to_h
        @data
      end
    end

    class MessageBuilder
      attr_reader :data

      def initialize
        @data = {
          content: nil,
          embeds: [],
          components: [],
          allowed_mentions: nil,
          message_reference: nil,
          flags: nil,
          poll: nil
        }
      end

      def self.build
        builder = new
        yield builder if block_given?
        builder.data.compact
      end

      def content(text)
        @data[:content] = text
        self
      end

      def add_embed
        embed = Embed.new
        yield embed if block_given?
        @data[:embeds] << embed.to_h
        self
      end

      def embed(title: nil, description: nil, color: nil)
        add_embed do |e|
          e.title(title) if title
          e.description(description) if description
          e.color(color) if color
          yield e if block_given?
        end
        self
      end

      def add_row
        row = Component::ActionRow.new
        yield row if block_given?
        @data[:components] << row.to_h
        self
      end

      def add_select(custom_id:, type: :string, options: [], placeholder: nil, min_values: 1, max_values: 1, disabled: false)
        component = case type
                    when :string then Component::StringSelectMenu.new(custom_id: custom_id, options: options, placeholder: placeholder, min_values: min_values, max_values: max_values, disabled: disabled)
                    when :user then Component::UserSelectMenu.new(custom_id: custom_id, placeholder: placeholder, min_values: min_values, max_values: max_values, disabled: disabled)
                    when :role then Component::RoleSelectMenu.new(custom_id: custom_id, placeholder: placeholder, min_values: min_values, max_values: max_values, disabled: disabled)
                    when :mentionable then Component::MentionableSelectMenu.new(custom_id: custom_id, placeholder: placeholder, min_values: min_values, max_values: max_values, disabled: disabled)
                    when :channel then Component::ChannelSelectMenu.new(custom_id: custom_id, placeholder: placeholder, min_values: min_values, max_values: max_values, disabled: disabled)
                    end
        
        row = @data[:components].last
        if row && row[:type] == Component::ActionRow::TYPE && row[:components].empty?
           row[:components] << component.to_h
        else
           add_row { |r| r.add_component(component) }
        end
        self
      end

      def string_select(custom_id:, **opts, &block)
        add_select(custom_id: custom_id, type: :string, **opts, &block)
      end

      def user_select(custom_id:, **opts)
        add_select(custom_id: custom_id, type: :user, **opts)
      end

      def role_select(custom_id:, **opts)
        add_select(custom_id: custom_id, type: :role, **opts)
      end

      def mentionable_select(custom_id:, **opts)
        add_select(custom_id: custom_id, type: :mentionable, **opts)
      end

      def channel_select(custom_id:, **opts)
        add_select(custom_id: custom_id, type: :channel, **opts)
      end

      def add_button(label: nil, custom_id: nil, style: :primary, url: nil, emoji: nil, disabled: false)
        btn_style = case style
                    when :primary then Interaction::ButtonStyle::PRIMARY
                    when :secondary then Interaction::ButtonStyle::SECONDARY
                    when :success then Interaction::ButtonStyle::SUCCESS
                    when :danger then Interaction::ButtonStyle::DANGER
                    when :link then Interaction::ButtonStyle::LINK
                    else style
                    end
        button = Component::Button.new(label: label, custom_id: custom_id, style: btn_style, url: url, emoji: emoji, disabled: disabled)
        
        row = @data[:components].last
        if row && row[:type] == Component::ActionRow::TYPE && row[:components].size < 5 && row[:components].none? { |c| c[:type] >= 3 }
           row[:components] << button.to_h
        else
           add_row { |r| r.add_component(button) }
        end
        self
      end

      def ephemeral
        @data[:flags] = 64
        self
      end

      def reply_to(message_id, guild_id: nil, fail_if_not_exists: true)
        @data[:message_reference] = {
          message_id: message_id,
          guild_id: guild_id,
          fail_if_not_exists: fail_if_not_exists
        }.compact
        self
      end

      def poll(question:, answers:, duration: 24, allow_multiselect: false, layout_type: 1)
        @data[:poll] = {
          question: { text: question },
          answers: answers.map { |a| { poll_media: a.is_a?(Hash) ? a : { text: a } } },
          duration: duration,
          allow_multiselect: allow_multiselect,
          layout_type: layout_type
        }
        self
      end
    end

    class GuildBuilder
      def initialize
        @data = {}
      end

      def name(val)
        @data[:name] = val
        self
      end

      def region(val)
        @data[:region] = val
        self
      end

      def verification_level(val)
        @data[:verification_level] = val
        self
      end

      def default_message_notifications(val)
        @data[:default_message_notifications] = val
        self
      end

      def explicit_content_filter(val)
        @data[:explicit_content_filter] = val
        self
      end

      def roles(val)
        @data[:roles] = val
        self
      end

      def channels(val)
        @data[:channels] = val
        self
      end

      def afk_channel_id(val)
        @data[:afk_channel_id] = val
        self
      end

      def afk_timeout(val)
        @data[:afk_timeout] = val
        self
      end

      def system_channel_id(val)
        @data[:system_channel_id] = val
        self
      end

      def system_channel_flags(val)
        @data[:system_channel_flags] = val
        self
      end

      def build
        @data.compact
      end
    end

    class ChannelBuilder
      def initialize
        @data = {}
      end

      def name(val)
        @data[:name] = val
        self
      end

      def type(val)
        @data[:type] = val
        self
      end

      def topic(val)
        @data[:topic] = val
        self
      end

      def bitrate(val)
        @data[:bitrate] = val
        self
      end

      def user_limit(val)
        @data[:user_limit] = val
        self
      end

      def rate_limit_per_user(val)
        @data[:rate_limit_per_user] = val
        self
      end

      def position(val)
        @data[:position] = val
        self
      end

      def permission_overwrites(val)
        @data[:permission_overwrites] = val
        self
      end

      def parent_id(val)
        @data[:parent_id] = val
        self
      end

      def nsfw(val)
        @data[:nsfw] = val
        self
      end

      def build
        @data.compact
      end
    end

    class RoleBuilder
      def initialize
        @data = {}
      end

      def name(val)
        @data[:name] = val
        self
      end

      def permissions(val)
        @data[:permissions] = val.is_a?(Bitfield) ? val.bits.to_s : val.to_s
        self
      end

      def color(val)
        @data[:color] = val
        self
      end

      def hoist(val)
        @data[:hoist] = val
        self
      end

      def icon(val)
        @data[:icon] = val
        self
      end

      def unicode_emoji(val)
        @data[:unicode_emoji] = val
        self
      end

      def mentionable(val)
        @data[:mentionable] = val
        self
      end

      def build
        @data.compact
      end
    end

    class InviteBuilder
      def initialize
        @data = {}
      end

      def max_age(val)
        @data[:max_age] = val
        self
      end

      def max_uses(val)
        @data[:max_uses] = val
        self
      end

      def temporary(val)
        @data[:temporary] = val
        self
      end

      def unique(val)
        @data[:unique] = val
        self
      end

      def target_type(val)
        @data[:target_type] = val
        self
      end

      def target_user_id(val)
        @data[:target_user_id] = val
        self
      end

      def target_application_id(val)
        @data[:target_application_id] = val
        self
      end

      def build
        @data.compact
      end
    end

    class WebhookBuilder
      def initialize
        @data = {}
      end

      def name(val)
        @data[:name] = val
        self
      end

      def avatar(val)
        @data[:avatar] = val
        self
      end

      def build
        @data.compact
      end
    end

    class ScheduledEventBuilder
      def initialize
        @data = {}
      end

      def channel_id(val)
        @data[:channel_id] = val
        self
      end

      def entity_metadata(val)
        @data[:entity_metadata] = val
        self
      end

      def name(val)
        @data[:name] = val
        self
      end

      def privacy_level(val)
        @data[:privacy_level] = val
        self
      end

      def scheduled_start_time(val)
        @data[:scheduled_start_time] = val.respond_to?(:iso8601) ? val.iso8601 : val
        self
      end

      def scheduled_end_time(val)
        @data[:scheduled_end_time] = val.respond_to?(:iso8601) ? val.iso8601 : val
        self
      end

      def description(val)
        @data[:description] = val
        self
      end

      def entity_type(val)
        @data[:entity_type] = val
        self
      end

      def image(val)
        @data[:image] = val
        self
      end

      def build
        @data.compact
      end
    end

    class AutoModerationRuleBuilder
      def initialize
        @data = {}
      end

      def name(val)
        @data[:name] = val
        self
      end

      def event_type(val)
        @data[:event_type] = val
        self
      end

      def trigger_type(val)
        @data[:trigger_type] = val
        self
      end

      def trigger_metadata(val)
        @data[:trigger_metadata] = val
        self
      end

      def actions(val)
        @data[:actions] = val
        self
      end

      def enabled(val)
        @data[:enabled] = val
        self
      end

      def exempt_roles(val)
        @data[:exempt_roles] = val
        self
      end

      def exempt_channels(val)
        @data[:exempt_channels] = val
        self
      end

      def build
        @data.compact
      end
    end

    class StickerBuilder
      def initialize
        @data = {}
      end

      def name(val)
        @data[:name] = val
        self
      end

      def description(val)
        @data[:description] = val
        self
      end

      def tags(val)
        @data[:tags] = val
        self
      end

      def file(val)
        @data[:file] = val
        self
      end

      def build
        @data.compact
      end
    end

    class StageInstanceBuilder
      def initialize
        @data = {}
      end

      def channel_id(val)
        @data[:channel_id] = val
        self
      end

      def topic(val)
        @data[:topic] = val
        self
      end

      def privacy_level(val)
        @data[:privacy_level] = val
        self
      end

      def build
        @data.compact
      end
    end

    class AllowedMentionsBuilder
      def initialize
        @data = {
          parse: [],
          roles: [],
          users: [],
          replied_user: false
        }
      end

      def parse_everyone
        @data[:parse] << 'everyone'
        self
      end

      def parse_roles
        @data[:parse] << 'roles'
        self
      end

      def parse_users
        @data[:parse] << 'users'
        self
      end

      def add_role(id)
        @data[:roles] << id
        self
      end

      def add_user(id)
        @data[:users] << id
        self
      end

      def replied_user(val = true)
        @data[:replied_user] = val
        self
      end

      def build
        @data.select { |_, v| !v.nil? && (!v.respond_to?(:empty?) || !v.empty?) }
      end
    end

    class ThreadBuilder
      def initialize
        @data = {}
      end

      def name(val)
        @data[:name] = val
        self
      end

      def auto_archive_duration(val)
        @data[:auto_archive_duration] = val
        self
      end

      def type(val)
        @data[:type] = val
        self
      end

      def invitable(val)
        @data[:invitable] = val
        self
      end

      def rate_limit_per_user(val)
        @data[:rate_limit_per_user] = val
        self
      end

      def build
        @data.compact
      end
    end

    class ForumPostBuilder
      def initialize
        @data = {
          message: {}
        }
      end

      def name(val)
        @data[:name] = val
        self
      end

      def content(val)
        @data[:message][:content] = val
        self
      end

      def add_embed
        builder = Embed.new
        yield builder if block_given?
        @data[:message][:embeds] ||= []
        @data[:message][:embeds] << builder.to_h
        self
      end

      def auto_archive_duration(val)
        @data[:auto_archive_duration] = val
        self
      end

      def rate_limit_per_user(val)
        @data[:rate_limit_per_user] = val
        self
      end

      def applied_tags(val)
        @data[:applied_tags] = val
        self
      end

      def build
        @data.compact
      end
    end

    class EmojiBuilder
      def initialize
        @data = {}
      end

      def name(val)
        @data[:name] = val
        self
      end

      def image(val)
        @data[:image] = val
        self
      end

      def roles(val)
        @data[:roles] = val
        self
      end

      def build
        @data.compact
      end
    end

    class SoundboardSoundBuilder
      def initialize
        @data = {}
      end

      def name(val)
        @data[:name] = val
        self
      end

      def sound(val)
        @data[:sound] = val
        self
      end

      def volume(val)
        @data[:volume] = val
        self
      end

      def emoji_id(val)
        @data[:emoji_id] = val
        self
      end

      def emoji_name(val)
        @data[:emoji_name] = val
        self
      end

      def build
        @data.compact
      end
    end

    class ApplicationRoleConnectionMetadataBuilder
      def initialize
        @data = {}
      end

      def type(val)
        @data[:type] = val
        self
      end

      def key(val)
        @data[:key] = val
        self
      end

      def name(val)
        @data[:name] = val
        self
      end

      def name_localizations(val)
        @data[:name_localizations] = val
        self
      end

      def description(val)
        @data[:description] = val
        self
      end

      def description_localizations(val)
        @data[:description_localizations] = val
        self
      end

      def build
        @data.compact
      end
    end
    class ModalBuilder
      def initialize(custom_id: nil, title: nil)
        @data = {
          title: title,
          custom_id: custom_id,
          components: []
        }
      end

      def title(val)
        @data[:title] = val
        self
      end

      def custom_id(val)
        @data[:custom_id] = val
        self
      end

      def add_text_input(label:, custom_id:, style: :short, placeholder: nil, min_length: nil, max_length: nil, required: true, value: nil)
        input_style = style == :paragraph ? Interaction::TextInputStyle::PARAGRAPH : Interaction::TextInputStyle::SHORT
        input = Component::TextInput.new(label: label, custom_id: custom_id, style: input_style, placeholder: placeholder, min_length: min_length, max_length: max_length, required: required, value: value)
        
        row = Component::ActionRow.new
        row.add_component(input)
        @data[:components] << row.to_h
        self
      end

      def build
        @data.compact
      end

      alias_method :to_h, :build
    end
  end
end
