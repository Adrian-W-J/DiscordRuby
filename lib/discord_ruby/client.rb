module DiscordRuby
  class Client < Bot
    def initialize(token:, **options)
      super(token: token, **options)
    end

    alias_method :login, :run!

    def on_ready(&block)
      on('READY') do |payload|
        @application_id = payload.dig('application', 'id')
        @ready = true
        block.call(payload)
      end
    end

    def on_message(&block)
      on('MESSAGE_CREATE') do |payload|
        block.call(Message.new(self, payload))
      end
    end

    def on_interaction(&block)
      on('INTERACTION_CREATE') do |payload|
        block.call(Interaction.from_data(self, payload))
      end
    end

    def on_message_update(&block)
      on('MESSAGE_UPDATE') { |p| block.call(Events::MessageUpdateEvent.new(self, p)) }
    end

    def on_message_delete(&block)
      on('MESSAGE_DELETE') { |p| block.call(Events::MessageDeleteEvent.new(self, p)) }
    end

    def on_guild_create(&block)
      on('GUILD_CREATE') { |p| block.call(Guild.new(self, p)) }
    end

    def on_guild_update(&block)
      on('GUILD_UPDATE') { |p| block.call(Guild.new(self, p)) }
    end

    def on_guild_delete(&block)
      on('GUILD_DELETE') { |p| block.call(p['unavailable'] ? p : Guild.new(self, p)) }
    end

    def on_channel_create(&block)
      on('CHANNEL_CREATE') { |p| block.call(Channel.from_data(self, p)) }
    end

    def on_channel_update(&block)
      on('CHANNEL_UPDATE') { |p| block.call(Channel.from_data(self, p)) }
    end

    def on_channel_delete(&block)
      on('CHANNEL_DELETE') { |p| block.call(Channel.from_data(self, p)) }
    end

    def on_member_add(&block)
      on('GUILD_MEMBER_ADD') { |p| block.call(Member.new(self, p)) }
    end

    def on_member_update(&block)
      on('GUILD_MEMBER_UPDATE') { |p| block.call(Member.new(self, p)) }
    end

    def on_member_remove(&block)
      on('GUILD_MEMBER_REMOVE') { |p| block.call(Member.new(self, p)) }
    end

    def on_reaction_add(&block)
      on('MESSAGE_REACTION_ADD') { |p| block.call(Events::MessageReactionAddEvent.new(self, p)) }
    end

    def on_reaction_remove(&block)
      on('MESSAGE_REACTION_REMOVE') { |p| block.call(Events::MessageReactionRemoveEvent.new(self, p)) }
    end

    def on_voice_state_update(&block)
      on('VOICE_STATE_UPDATE') { |p| block.call(VoiceState.new(self, p)) }
    end

    def on_presence_update(&block)
      on('PRESENCE_UPDATE') { |p| block.call(Presence.new(self, p)) }
    end

    def on_typing_start(&block)
      on('TYPING_START') { |p| block.call(p) }
    end

    def on_ban_add(&block)
      on('GUILD_BAN_ADD') { |p| block.call(p) }
    end

    def on_ban_remove(&block)
      on('GUILD_BAN_REMOVE') { |p| block.call(p) }
    end

    def on_invite_create(&block)
      on('INVITE_CREATE') { |p| block.call(Invite.new(self, p)) }
    end

    def on_invite_delete(&block)
      on('INVITE_DELETE') { |p| block.call(Invite.new(self, p)) }
    end

    def on_thread_create(&block)
      on('THREAD_CREATE') { |p| block.call(ThreadChannel.new(self, p)) }
    end

    def on_thread_update(&block)
      on('THREAD_UPDATE') { |p| block.call(ThreadChannel.new(self, p)) }
    end

    def on_thread_delete(&block)
      on('THREAD_DELETE') { |p| block.call(Channel.from_data(self, p)) }
    end

    def on_stage_instance_create(&block)
      on('STAGE_INSTANCE_CREATE') { |p| block.call(StageInstance.new(self, p)) }
    end

    def on_stage_instance_update(&block)
      on('STAGE_INSTANCE_UPDATE') { |p| block.call(StageInstance.new(self, p)) }
    end

    def on_stage_instance_delete(&block)
      on('STAGE_INSTANCE_DELETE') { |p| block.call(StageInstance.new(self, p)) }
    end

    def on_scheduled_event_create(&block)
      on('GUILD_SCHEDULED_EVENT_CREATE') { |p| block.call(ScheduledEvent.new(self, p)) }
    end

    def on_scheduled_event_update(&block)
      on('GUILD_SCHEDULED_EVENT_UPDATE') { |p| block.call(ScheduledEvent.new(self, p)) }
    end

    def on_scheduled_event_delete(&block)
      on('GUILD_SCHEDULED_EVENT_DELETE') { |p| block.call(ScheduledEvent.new(self, p)) }
    end

    def on_auto_moderation_rule_create(&block)
      on('AUTO_MODERATION_RULE_CREATE') { |p| block.call(AutoModerationRule.new(self, p)) }
    end

    def on_auto_moderation_rule_update(&block)
      on('AUTO_MODERATION_RULE_UPDATE') { |p| block.call(AutoModerationRule.new(self, p)) }
    end

    def on_auto_moderation_rule_delete(&block)
      on('AUTO_MODERATION_RULE_DELETE') { |p| block.call(AutoModerationRule.new(self, p)) }
    end

    def on_auto_moderation_action_execution(&block)
      on('AUTO_MODERATION_ACTION_EXECUTION') { |p| block.call(p) }
    end

    def on_entitlement_create(&block)
      on('ENTITLEMENT_CREATE') { |p| block.call(p) }
    end

    def on_entitlement_update(&block)
      on('ENTITLEMENT_UPDATE') { |p| block.call(p) }
    end

    def on_entitlement_delete(&block)
      on('ENTITLEMENT_DELETE') { |p| block.call(p) }
    end

    def on_audit_log_entry_create(&block)
      on('GUILD_AUDIT_LOG_ENTRY_CREATE') { |p| block.call(AuditLogEntry.new(self, p)) }
    end

    def on_voice_server_update(&block)
      on('VOICE_SERVER_UPDATE') { |p| block.call(p) }
    end

    def on_webhooks_update(&block)
      on('WEBHOOKS_UPDATE') { |p| block.call(p) }
    end

    def on_integration_create(&block)
      on('GUILD_INTEGRATIONS_UPDATE') { |p| block.call(p) }
    end

    def on_sticker_update(&block)
      on('GUILD_STICKERS_UPDATE') { |p| block.call(p) }
    end

    def on_emoji_update(&block)
      on('GUILD_EMOJIS_UPDATE') { |p| block.call(p) }
    end

    def on_role_create(&block)
      on('GUILD_ROLE_CREATE') { |p| block.call(Role.new(self, p['role'].merge('guild_id' => p['guild_id']))) }
    end

    def on_role_update(&block)
      on('GUILD_ROLE_UPDATE') { |p| block.call(Role.new(self, p['role'].merge('guild_id' => p['guild_id']))) }
    end

    def on_role_delete(&block)
      on('GUILD_ROLE_DELETE') { |p| block.call(p) }
    end

    def on_application_command_permissions_update(&block)
      on('APPLICATION_COMMAND_PERMISSIONS_UPDATE') { |p| block.call(p) }
    end

    def on_poll_vote_add(&block)
      on('MESSAGE_POLL_VOTE_ADD') { |p| block.call(p) }
    end

    def on_poll_vote_remove(&block)
      on('MESSAGE_POLL_VOTE_REMOVE') { |p| block.call(p) }
    end

    def users
      @users ||= Managers::UserManager.new(self)
    end

    def guilds
      @guilds ||= Managers::GuildManager.new(self)
    end

    def channels
      @channels ||= Managers::ChannelManager.new(self)
    end

    def application_commands
      @application_commands ||= Managers::ApplicationCommandManager.new(self)
    end

    def send_message(channel_id, content = nil, **options, &block)
      super(channel_id, content, **options, &block)
    end

    def user
      @me || fetch_my_user
    end

    def self.simple_bot(token)
      client = new(token: token)
      client.on_message do |msg|
        next if msg.author&.bot?
        yield msg if block_given?
      end
      client.run!
    end
  end
end
