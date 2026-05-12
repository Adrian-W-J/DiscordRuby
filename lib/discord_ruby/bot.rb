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
      @interaction_handlers << block
    end

    def on_ready(&block)
      on('READY', &block)
    end

    def run!
      @gateway.run
    end

    def register_global_command(application_id, data)
      create_global_application_command(application_id, data)
    end

    def register_guild_command(application_id, guild_id, data)
      create_guild_application_command(application_id, guild_id, data)
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
      @current_interaction_token = payload['token']

      @interaction_handlers.each do |handler|
        handler.call(payload)
      rescue StandardError => error
        dispatch_error(error)
      end

      case payload['type']
      when Interaction::InteractionType::APPLICATION_COMMAND
        command_name = payload.dig('data', 'name')
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
