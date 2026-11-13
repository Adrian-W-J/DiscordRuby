module DiscordRuby
  module Interaction
    def self.from_data(bot, payload)
      case payload['type']
      when InteractionType::APPLICATION_COMMAND
        CommandInteraction.new(bot, payload)
      when InteractionType::MESSAGE_COMPONENT
        MessageComponentInteraction.new(bot, payload)
      when InteractionType::MODAL_SUBMIT
        ModalSubmitInteraction.new(bot, payload)
      when InteractionType::APPLICATION_COMMAND_AUTOCOMPLETE
        AutocompleteInteraction.new(bot, payload)
      else
        BaseInteraction.new(bot, payload)
      end
    end

    module ResponseType
      PONG = 1
      CHANNEL_MESSAGE_WITH_SOURCE = 4
      DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE = 5
      DEFERRED_UPDATE_MESSAGE = 6
      UPDATE_MESSAGE = 7
      APPLICATION_COMMAND_AUTOCOMPLETE_RESULT = 8
      MODAL = 9
      PREMIUM_REQUIRED = 10
    end

    module InteractionType
      PING = 1
      APPLICATION_COMMAND = 2
      MESSAGE_COMPONENT = 3
      APPLICATION_COMMAND_AUTOCOMPLETE = 4
      MODAL_SUBMIT = 5
    end

    module ApplicationCommandType
      CHAT_INPUT = 1
      USER = 2
      MESSAGE = 3
    end

    module ApplicationCommandOptionType
      SUB_COMMAND = 1
      SUB_COMMAND_GROUP = 2
      STRING = 3
      INTEGER = 4
      BOOLEAN = 5
      USER = 6
      CHANNEL = 7
      ROLE = 8
      MENTIONABLE = 9
      NUMBER = 10
      ATTACHMENT = 11
    end

    module ComponentType
      ACTION_ROW = 1
      BUTTON = 2
      STRING_SELECT = 3
      TEXT_INPUT = 4
      USER_SELECT = 5
      ROLE_SELECT = 6
      MENTIONABLE_SELECT = 7
      CHANNEL_SELECT = 8
      SECTION = 9
      TEXT_DISPLAY = 10
      THUMBNAIL = 11
      MEDIA_GALLERY = 12
      FILE = 13
      SEPARATOR = 14
      CONTAINER = 17
      LABEL = 18
      FILE_UPLOAD = 19
      RADIO_GROUP = 21
      CHECKBOX_GROUP = 22
      CHECKBOX = 23
    end

    module ButtonStyle
      PRIMARY = 1
      SECONDARY = 2
      SUCCESS = 3
      DANGER = 4
      LINK = 5
      PREMIUM = 6
    end

    module TextInputStyle
      SHORT = 1
      PARAGRAPH = 2
    end

    module MessageFlags
      CROSSPOSTED = 1 << 0
      IS_CROSSPOST = 1 << 1
      SUPPRESS_EMBEDS = 1 << 2
      SOURCE_MESSAGE_DELETED = 1 << 3
      URGENT = 1 << 4
      HAS_THREAD = 1 << 5
      EPHEMERAL = 1 << 6
      LOADING = 1 << 7
      FAILED_TO_MENTION_SOME_ROLES_IN_THREAD = 1 << 8
      SUPPRESS_NOTIFICATIONS = 1 << 12
      IS_VOICE_MESSAGE = 1 << 13
      IS_COMPONENTS_V2 = 1 << 15
    end

    module ChannelType
      GUILD_TEXT = 0
      DM = 1
      GUILD_VOICE = 2
      GROUP_DM = 3
      GUILD_CATEGORY = 4
      GUILD_ANNOUNCEMENT = 5
      ANNOUNCEMENT_THREAD = 10
      PUBLIC_THREAD = 11
      PRIVATE_THREAD = 12
      GUILD_STAGE_VOICE = 13
      GUILD_DIRECTORY = 14
      GUILD_FORUM = 15
      GUILD_MEDIA = 16
    end

    module UserFlags
      STAFF = 1 << 0
      PARTNER = 1 << 1
      HYPESQUAD = 1 << 2
      BUG_HUNTER_LEVEL_1 = 1 << 3
      HYPESQUAD_ONLINE_HOUSE_1 = 1 << 6
      HYPESQUAD_ONLINE_HOUSE_2 = 1 << 7
      HYPESQUAD_ONLINE_HOUSE_3 = 1 << 8
      PREMIUM_EARLY_SUPPORTER = 1 << 9
      TEAM_PSEUDO_USER = 1 << 10
      BUG_HUNTER_LEVEL_2 = 1 << 14
      VERIFIED_BOT = 1 << 16
      VERIFIED_DEVELOPER = 1 << 17
      CERTIFIED_MODERATOR = 1 << 18
      BOT_HTTP_INTERACTIONS = 1 << 19
      ACTIVE_DEVELOPER = 1 << 22
    end
  end

  def self.from_data(bot, payload)
    Interaction.from_data(bot, payload)
  end

  class BaseInteraction
    attr_reader :context, :authorizing_integration_owners, :attachment_size_limit
    attr_reader :bot, :id, :application_id, :type, :data, :guild_id, :channel_id, :member, :user, :token, :version, :app_permissions, :locale, :guild_locale, :entitlements

    def initialize(bot, payload)
      @bot = bot
      @id = payload['id']
      @application_id = payload['application_id']
      @type = payload['type']
      @data = payload['data'] || {}
      @locale = payload['locale']
      @guild_locale = payload['guild_locale']
      @context = payload['context']
      @authorizing_integration_owners = payload['authorizing_integration_owners'] || {}
      @entitlements = payload['entitlements'] || []
      @attachment_size_limit = payload['attachment_size_limit']
      @guild_id = payload['guild_id']
      @channel_id = payload['channel_id']
      @token = payload['token']
      @version = payload['version']
      @member = Member.new(bot, payload['member'].merge('guild_id' => @guild_id)) if payload['member']
      user_data = payload['user'] || payload.dig('member', 'user')
      @user = User.new(bot, user_data) if user_data
      @app_permissions = Permissions.new(payload['app_permissions']) if payload['app_permissions']
      @replied = false
      @deferred = false
    end

    def replied?
      @replied
    end

    def deferred?
      @deferred
    end

    def fetch_reply
      @bot.get_original_interaction_response(@application_id, @token)
    end

    def reply(ephemeral: false, flags: nil, **data)
      raise "Interaction already replied to" if @replied

      data[:flags] = (flags || 0) | Interaction::MessageFlags::EPHEMERAL if ephemeral
      data[:flags] = flags if flags && !ephemeral
      @bot.respond_to_interaction(@id, @token, Interaction::ResponseType::CHANNEL_MESSAGE_WITH_SOURCE, data.compact)
      @replied = true
    end

    def defer_reply(ephemeral: false)
      raise "Interaction already replied to" if @replied

      flags = ephemeral ? Interaction::MessageFlags::EPHEMERAL : 0
      @bot.respond_to_interaction(@id, @token, Interaction::ResponseType::DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE, { flags: flags })
      @deferred = true
      @replied = true
    end

    def edit_reply(**data)
      @bot.edit_original_interaction_response(@application_id, @token, data)
    end

    def follow_up(ephemeral: false, flags: nil, **data)
      data[:flags] = (flags || 0) | Interaction::MessageFlags::EPHEMERAL if ephemeral
      data[:flags] = flags if flags && !ephemeral
      @bot.create_followup_message(@application_id, @token, data.compact)
    end

    def delete_reply
      @bot.delete_original_interaction_response(@application_id, @token)
    end

    def show_modal(modal)
      raise "Interaction already replied to" if @replied
      @bot.create_modal_response(@id, @token, modal)
      @replied = true
    end
  end

  class CommandInteraction < BaseInteraction
    attr_reader :command_name, :options, :command_type, :target_id, :resolved

    def initialize(bot, payload)
      super
      @command_name = @data['name']
      @options = @data['options'] || []
      @command_type = @data['type'] || Interaction::ApplicationCommandType::CHAT_INPUT
      @target_id = @data['target_id']
      @resolved = @data['resolved'] || {}
    end

    def get_option(name)
      @options.find { |opt| opt['name'] == name }&.fetch('value', nil)
    end

    def resolved_option(name, *subcommands)
      options = @options
      subcommands.each do |subcommand|
        options = options.find { |option| option['name'] == subcommand }&.fetch('options', []) || []
      end
      option = options.find { |item| item['name'] == name }
      return unless option

      id = option['value']
      case option['type']
      when 6
        resolved_user(id)
      when 7
        data = @resolved.dig('channels', id)
        Channel.new(@bot, data) if data
      when 8
        resolved_role(id)
      when 9
        resolved_role(id) || resolved_user(id)
      when 11
        data = @resolved.dig('attachments', id)
        Attachment.new(@bot, data) if data
      else
        id
      end
    end

    def target
      case @command_type
      when Interaction::ApplicationCommandType::USER
        data = @resolved.dig('users', @target_id)
        User.new(@bot, data) if data
      when Interaction::ApplicationCommandType::MESSAGE
        data = @resolved.dig('messages', @target_id)
        Message.new(@bot, data) if data
      end
    end

    private

    def resolved_user(id)
      user = @resolved.dig('users', id)
      return unless user

      member = @resolved.dig('members', id)
      return User.new(@bot, user) unless member

      Member.new(@bot, member.merge('user' => user, 'guild_id' => @guild_id))
    end

    def resolved_role(id)
      role = @resolved.dig('roles', id)
      Role.new(@bot, role.merge('guild_id' => @guild_id)) if role
    end
  end

  class AutocompleteInteraction < CommandInteraction
    def focused_option
      options = @options
      until options.empty?
        focused = options.find { |option| option['focused'] }
        return focused if focused

        options = options.flat_map { |option| option.fetch('options', []) }
      end
      nil
    end

    def respond(choices)
      raise 'Interaction already replied to' if @replied
      raise ArgumentError, 'autocomplete accepts at most 25 choices' unless choices.is_a?(Array) && choices.size <= 25

      response = @bot.create_autocomplete_response(@id, @token, choices)
      @replied = true
      response
    end
  end

  class MessageComponentInteraction < BaseInteraction
    attr_reader :custom_id, :component_type, :values, :message

    def initialize(bot, payload)
      super
      @custom_id = @data['custom_id']
      @component_type = @data['component_type']
      @values = @data['values'] || []
      @message = Message.new(bot, payload['message']) if payload['message']
    end

    def update(**data)
      raise "Interaction already replied to" if @replied

      @bot.respond_to_interaction(@id, @token, Interaction::ResponseType::UPDATE_MESSAGE, data)
      @replied = true
    end

    def defer_update
      raise "Interaction already replied to" if @replied
      @bot.respond_to_interaction(@id, @token, Interaction::ResponseType::DEFERRED_UPDATE_MESSAGE)
      @deferred = true
      @replied = true
    end
  end

  class ModalSubmitInteraction < BaseInteraction
    attr_reader :custom_id, :fields, :resolved

    def initialize(bot, payload)
      super
      @custom_id = @data['custom_id']
      @fields = {}
      @resolved = @data['resolved'] || {}
      collect_fields(@data['components'] || [])
    end

    def files(custom_id)
      Array(@fields[custom_id]).filter_map do |id|
        attachment = @resolved.dig('attachments', id)
        Attachment.new(@bot, attachment) if attachment
      end
    end

    private

    def collect_fields(components)
      components.each do |component|
        if component['custom_id']
          @fields[component['custom_id']] = component.fetch('values') { component['value'] }
        end
        collect_fields(component['components']) if component['components']
        collect_fields([component['component']]) if component['component']
      end
    end
  end
end
