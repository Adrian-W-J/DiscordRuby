module DiscordRuby
  class Bot < APIClient
    attr_reader :gateway, :users, :guilds, :channels, :members, :messages, :application_id
    attr_accessor :ready

    def initialize(token:, intents: 513, gateway_url: nil, cache_size: 1000)
      super(token: token)
      @gateway = Gateway.new(token: token, intents: intents, gateway_url: gateway_url)
      @command_registry = CommandRegistry.new
      @autocomplete_registry = CommandRegistry.new
      @component_handlers = Hash.new { |hash, key| hash[key] = [] }
      @modal_handlers = Hash.new { |hash, key| hash[key] = [] }
      @interaction_handlers = []
      @users = Cache.new(limit: cache_size)
      @guilds = Cache.new(limit: cache_size)
      @channels = Cache.new(limit: cache_size)
      @members = Cache.new(limit: cache_size)
      @messages = Cache.new(limit: cache_size)
      @ready = false

      attach_default_handlers
    end

    def on(event, &block)
      @gateway.on(event, &block)
    end

    def off(event, handler_id)
      @gateway.off(event, handler_id)
    end

    def on_command(name, &block)
      @command_registry.register(name, &block)
    end

    def on_autocomplete(name, &block)
      @autocomplete_registry.register(name, &block)
    end

    def on_component(custom_id, &block)
      @component_handlers[custom_id.to_s] << block
    end

    def on_modal_submit(custom_id, &block)
      @modal_handlers[custom_id.to_s] << block
    end

    def on_interaction(&block)
      handler_id = SecureRandom.uuid
      @interaction_handlers << { id: handler_id, block: block }
      handler_id
    end

    def off_interaction(handler_id)
      @interaction_handlers.reject! { |h| h[:id] == handler_id }
    end

    def on_ready(&block)
      on('READY') do |payload|
        # Ensure application_id is set before calling the block
        @application_id = payload.dig('application', 'id')
        @ready = true
        block.call(payload)
      end
    end

    def on_message(&block)
      on('MESSAGE_CREATE', &block)
    end

    def on_message_update(&block)
      on('MESSAGE_UPDATE', &block)
    end

    def on_message_delete(&block)
      on('MESSAGE_DELETE', &block)
    end

    def on_guild_create(&block)
      on('GUILD_CREATE', &block)
    end

    def on_guild_update(&block)
      on('GUILD_UPDATE', &block)
    end

    def on_guild_delete(&block)
      on('GUILD_DELETE', &block)
    end

    def on_member_add(&block)
      on('GUILD_MEMBER_ADD', &block)
    end

    def on_member_update(&block)
      on('GUILD_MEMBER_UPDATE', &block)
    end

    def on_member_remove(&block)
      on('GUILD_MEMBER_REMOVE', &block)
    end

    def on_reaction_add(&block)
      on('MESSAGE_REACTION_ADD', &block)
    end

    def on_reaction_remove(&block)
      on('MESSAGE_REACTION_REMOVE', &block)
    end

    def on_reaction_remove_all(&block)
      on('MESSAGE_REACTION_REMOVE_ALL', &block)
    end

    def on_reaction_remove_emoji(&block)
      on('MESSAGE_REACTION_REMOVE_EMOJI', &block)
    end

    def on_typing_start(&block)
      on('TYPING_START', &block)
    end

    def on_voice_state_update(&block)
      on('VOICE_STATE_UPDATE', &block)
    end

    def on_voice_server_update(&block)
      on('VOICE_SERVER_UPDATE', &block)
    end

    def on_thread_create(&block)
      on('THREAD_CREATE', &block)
    end

    def on_thread_update(&block)
      on('THREAD_UPDATE', &block)
    end

    def on_thread_delete(&block)
      on('THREAD_DELETE', &block)
    end

    def on_thread_list_sync(&block)
      on('THREAD_LIST_SYNC', &block)
    end

    def on_thread_member_update(&block)
      on('THREAD_MEMBER_UPDATE', &block)
    end

    def on_thread_members_update(&block)
      on('THREAD_MEMBERS_UPDATE', &block)
    end

    def on_guild_ban_add(&block)
      on('GUILD_BAN_ADD', &block)
    end

    def on_guild_ban_remove(&block)
      on('GUILD_BAN_REMOVE', &block)
    end

    def on_guild_emojis_update(&block)
      on('GUILD_EMOJIS_UPDATE', &block)
    end

    def on_guild_stickers_update(&block)
      on('GUILD_STICKERS_UPDATE', &block)
    end

    def on_guild_integrations_update(&block)
      on('GUILD_INTEGRATIONS_UPDATE', &block)
    end

    def on_guild_role_create(&block)
      on('GUILD_ROLE_CREATE', &block)
    end

    def on_guild_role_update(&block)
      on('GUILD_ROLE_UPDATE', &block)
    end

    def on_guild_role_delete(&block)
      on('GUILD_ROLE_DELETE', &block)
    end

    def on_guild_scheduled_event_create(&block)
      on('GUILD_SCHEDULED_EVENT_CREATE', &block)
    end

    def on_guild_scheduled_event_update(&block)
      on('GUILD_SCHEDULED_EVENT_UPDATE', &block)
    end

    def on_guild_scheduled_event_delete(&block)
      on('GUILD_SCHEDULED_EVENT_DELETE', &block)
    end

    def on_guild_scheduled_event_user_add(&block)
      on('GUILD_SCHEDULED_EVENT_USER_ADD', &block)
    end

    def on_guild_scheduled_event_user_remove(&block)
      on('GUILD_SCHEDULED_EVENT_USER_REMOVE', &block)
    end

    def on_integration_create(&block)
      on('INTEGRATION_CREATE', &block)
    end

    def on_integration_update(&block)
      on('INTEGRATION_UPDATE', &block)
    end

    def on_integration_delete(&block)
      on('INTEGRATION_DELETE', &block)
    end

    def on_invite_create(&block)
      on('INVITE_CREATE', &block)
    end

    def on_invite_delete(&block)
      on('INVITE_DELETE', &block)
    end

    def on_presence_update(&block)
      on('PRESENCE_UPDATE', &block)
    end

    def on_stage_instance_create(&block)
      on('STAGE_INSTANCE_CREATE', &block)
    end

    def on_stage_instance_update(&block)
      on('STAGE_INSTANCE_UPDATE', &block)
    end

    def on_stage_instance_delete(&block)
      on('STAGE_INSTANCE_DELETE', &block)
    end

    def on_webhooks_update(&block)
      on('WEBHOOKS_UPDATE', &block)
    end

    def on_auto_moderation_rule_create(&block)
      on('AUTO_MODERATION_RULE_CREATE', &block)
    end

    def on_auto_moderation_rule_update(&block)
      on('AUTO_MODERATION_RULE_UPDATE', &block)
    end

    def on_auto_moderation_rule_delete(&block)
      on('AUTO_MODERATION_RULE_DELETE', &block)
    end

    def on_auto_moderation_action_execution(&block)
      on('AUTO_MODERATION_ACTION_EXECUTION', &block)
    end

    def bulk_overwrite_global_commands(commands)
      bulk_overwrite_global_application_commands(@application_id, commands)
    end

    def bulk_overwrite_guild_commands(guild_id, commands)
      bulk_overwrite_guild_application_commands(@application_id, guild_id, commands)
    end

    def delete_command(command_id, guild_id: nil)
      delete_application_command(@application_id, command_id, guild_id: guild_id)
    end

    def run!
      @gateway.run
    end

    def stop!
      @gateway.disconnect
    end

    def register_global_command(data)
      create_global_application_command(@application_id, data)
    end

    def register_guild_command(guild_id, data)
      create_guild_application_command(@application_id, guild_id, data)
    end

    def respond_to_interaction(interaction_id, interaction_token, type, data = {})
      create_interaction_response(interaction_id, interaction_token, type, data)
    end

    def show_modal(interaction_id, interaction_token, modal)
      create_modal_response(interaction_id, interaction_token, modal)
    end

    def respond_autocomplete(interaction_id, interaction_token, choices)
      create_autocomplete_response(interaction_id, interaction_token, choices)
    end

    def edit_interaction_response(data = {})
      edit_original_interaction_response(@application_id, @current_interaction_token, data)
    end

    def delete_interaction_response
      delete_original_interaction_response(@application_id, @current_interaction_token)
    end

    def followup_interaction(interaction_token, data = {})
      create_followup_message(@application_id, interaction_token, data)
    end

    def create_dm_channel(user_id)
      super(user_id)
    end

    def reply(event, content:, embeds: [], components: [], flags: nil)
      data = {content: content}
      data[:embeds] = embeds if embeds && !embeds.empty?
      data[:components] = components if components && !components.empty?
      data[:flags] = flags if flags
      respond_to_interaction(event['id'], event['token'], Interaction::ResponseType::CHANNEL_MESSAGE_WITH_SOURCE, data)
    end

    private

    def attach_default_handlers
      on('READY') do |payload|
        @application_id = payload.dig('application', 'id')
        @ready = true
      end

      on('INTERACTION_CREATE') do |payload|
        handle_interaction_create(payload)
      end
    end

    def handle_interaction_create(payload)
      puts "[DEBUG] Handling interaction: #{payload['type']} (Name: #{payload.dig('data', 'name') || payload.dig('data', 'custom_id')})" if ENV['DEBUG']
      @current_interaction_token = payload['token']

      @interaction_handlers.each do |handler|
        handler[:block].call(payload)
      rescue StandardError => error
        dispatch_error(error)
      end

      case payload['type']
      when Interaction::InteractionType::APPLICATION_COMMAND
        command_name = payload.dig('data', 'name')
        puts "[DEBUG] Dispatching command: #{command_name}" if ENV['DEBUG']
        @command_registry.dispatch(command_name, payload)
      when Interaction::InteractionType::APPLICATION_COMMAND_AUTOCOMPLETE
        command_name = payload.dig('data', 'name')
        @autocomplete_registry.dispatch(command_name, payload)
      when Interaction::InteractionType::MESSAGE_COMPONENT
        custom_id = payload.dig('data', 'custom_id')
        @component_handlers[custom_id].each { |handler| handler.call(payload) }
      when Interaction::InteractionType::MODAL_SUBMIT
        custom_id = payload.dig('data', 'custom_id')
        @modal_handlers[custom_id].each { |handler| handler.call(payload) }
      end
    rescue StandardError => error
      dispatch_error(error)
    end

    def dispatch_error(error)
      @gateway.dispatch('error', error)
    end
  end
end
