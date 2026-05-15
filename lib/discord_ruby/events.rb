module DiscordRuby
  module Events
    class BaseEvent
      attr_reader :bot, :data

      def initialize(bot, data)
        @bot = bot
        @data = data
      end
    end

    class ReadyEvent < BaseEvent
      attr_reader :v, :user, :guilds, :session_id, :resume_gateway_url, :shard

      def initialize(bot, data)
        super
        @v = data['v']
        @user = User.new(bot, data['user'])
        @guilds = data['guilds']
        @session_id = data['session_id']
        @resume_gateway_url = data['resume_gateway_url']
        @shard = data['shard']
      end
    end

    class MessageCreateEvent < BaseEvent
      attr_reader :message

      def initialize(bot, data)
        super
        @message = Message.new(bot, data)
      end
    end

    class MessageUpdateEvent < BaseEvent
      attr_reader :message

      def initialize(bot, data)
        super
        @message = Message.new(bot, data)
      end
    end

    class MessageDeleteEvent < BaseEvent
      attr_reader :id, :channel_id, :guild_id

      def initialize(bot, data)
        super
        @id = data['id']
        @channel_id = data['channel_id']
        @guild_id = data['guild_id']
      end
    end

    class GuildCreateEvent < BaseEvent
      attr_reader :guild

      def initialize(bot, data)
        super
        @guild = Guild.new(bot, data)
      end
    end

    class GuildUpdateEvent < BaseEvent
      attr_reader :guild

      def initialize(bot, data)
        super
        @guild = Guild.new(bot, data)
      end
    end

    class GuildDeleteEvent < BaseEvent
      attr_reader :id, :unavailable

      def initialize(bot, data)
        super
        @id = data['id']
        @unavailable = data['unavailable']
      end
    end

    class InteractionCreateEvent < BaseEvent
      attr_reader :interaction

      def initialize(bot, data)
        super
        @interaction = Interaction.from_data(bot, data)
      end
    end

    class ChannelCreateEvent < BaseEvent
      attr_reader :channel

      def initialize(bot, data)
        super
        @channel = Channel.from_data(bot, data)
      end
    end

    class ChannelUpdateEvent < BaseEvent
      attr_reader :channel

      def initialize(bot, data)
        super
        @channel = Channel.from_data(bot, data)
      end
    end

    class ChannelDeleteEvent < BaseEvent
      attr_reader :channel

      def initialize(bot, data)
        super
        @channel = Channel.from_data(bot, data)
      end
    end

    class GuildMemberAddEvent < BaseEvent
      attr_reader :member

      def initialize(bot, data)
        super
        @member = Member.new(bot, data)
      end
    end

    class GuildMemberUpdateEvent < BaseEvent
      attr_reader :member

      def initialize(bot, data)
        super
        @member = Member.new(bot, data)
      end
    end

    class GuildMemberRemoveEvent < BaseEvent
      attr_reader :user, :guild_id

      def initialize(bot, data)
        super
        @user = User.new(bot, data['user'])
        @guild_id = data['guild_id']
      end
    end

    class VoiceStateUpdateEvent < BaseEvent
      attr_reader :voice_state

      def initialize(bot, data)
        super
        @voice_state = VoiceState.new(bot, data)
      end
    end

    class PresenceUpdateEvent < BaseEvent
      attr_reader :presence

      def initialize(bot, data)
        super
        @presence = Presence.new(bot, data)
      end
    end

    class TypingStartEvent < BaseEvent
      attr_reader :channel_id, :guild_id, :user_id, :timestamp, :member

      def initialize(bot, data)
        super
        @channel_id = data['channel_id']
        @guild_id = data['guild_id']
        @user_id = data['user_id']
        @timestamp = data['timestamp']
        @member = Member.new(bot, data['member'].merge('guild_id' => data['guild_id'])) if data['member']
      end
    end

    class MessageReactionAddEvent < BaseEvent
      attr_reader :user_id, :channel_id, :message_id, :guild_id, :member, :emoji

      def initialize(bot, data)
        super
        @user_id = data['user_id']
        @channel_id = data['channel_id']
        @message_id = data['message_id']
        @guild_id = data['guild_id']
        @member = Member.new(bot, data['member'].merge('guild_id' => data['guild_id'])) if data['member']
        @emoji = data['emoji']
      end
    end

    class MessageReactionRemoveEvent < BaseEvent
      attr_reader :user_id, :channel_id, :message_id, :guild_id, :emoji

      def initialize(bot, data)
        super
        @user_id = data['user_id']
        @channel_id = data['channel_id']
        @message_id = data['message_id']
        @guild_id = data['guild_id']
        @emoji = data['emoji']
      end
    end

    class GuildBanAddEvent < BaseEvent
      attr_reader :guild_id, :user

      def initialize(bot, data)
        super
        @guild_id = data['guild_id']
        @user = User.new(bot, data['user'])
      end
    end

    class GuildBanRemoveEvent < BaseEvent
      attr_reader :guild_id, :user

      def initialize(bot, data)
        super
        @guild_id = data['guild_id']
        @user = User.new(bot, data['user'])
      end
    end

    class GuildEmojisUpdateEvent < BaseEvent
      attr_reader :guild_id, :emojis

      def initialize(bot, data)
        super
        @guild_id = data['guild_id']
        @emojis = data['emojis'].map { |e| Emoji.new(bot, e.merge('guild_id' => data['guild_id'])) }
      end
    end

    class GuildStickersUpdateEvent < BaseEvent
      attr_reader :guild_id, :stickers

      def initialize(bot, data)
        super
        @guild_id = data['guild_id']
        @stickers = data['stickers'].map { |s| Sticker.new(bot, s.merge('guild_id' => data['guild_id'])) }
      end
    end

    class GuildIntegrationsUpdateEvent < BaseEvent
      attr_reader :guild_id

      def initialize(bot, data)
        super
        @guild_id = data['guild_id']
      end
    end

    class WebhooksUpdateEvent < BaseEvent
      attr_reader :guild_id, :channel_id

      def initialize(bot, data)
        super
        @guild_id = data['guild_id']
        @channel_id = data['channel_id']
      end
    end

    class InviteCreateEvent < BaseEvent
      attr_reader :channel_id, :code, :created_at, :guild_id, :inviter, :max_age, :max_uses, :target_type, :target_user, :temporary, :uses

      def initialize(bot, data)
        super
        @channel_id = data['channel_id']
        @code = data['code']
        @created_at = data['created_at']
        @guild_id = data['guild_id']
        @inviter = User.new(bot, data['inviter']) if data['inviter']
        @max_age = data['max_age']
        @max_uses = data['max_uses']
        @target_type = data['target_type']
        @target_user = User.new(bot, data['target_user']) if data['target_user']
        @temporary = data['temporary']
        @uses = data['uses']
      end
    end

    class InviteDeleteEvent < BaseEvent
      attr_reader :channel_id, :guild_id, :code

      def initialize(bot, data)
        super
        @channel_id = data['channel_id']
        @guild_id = data['guild_id']
        @code = data['code']
      end
    end

    class AutoModerationRuleCreateEvent < BaseEvent
      attr_reader :rule

      def initialize(bot, data)
        super
        @rule = AutoModerationRule.new(bot, data)
      end
    end

    class AutoModerationRuleUpdateEvent < BaseEvent
      attr_reader :rule

      def initialize(bot, data)
        super
        @rule = AutoModerationRule.new(bot, data)
      end
    end

    class AutoModerationRuleDeleteEvent < BaseEvent
      attr_reader :rule

      def initialize(bot, data)
        super
        @rule = AutoModerationRule.new(bot, data)
      end
    end

    class AutoModerationActionExecutionEvent < BaseEvent
      attr_reader :guild_id, :action, :rule_id, :rule_trigger_type, :user_id, :channel_id, :message_id, :alert_system_message_id, :content, :matched_keyword, :matched_content

      def initialize(bot, data)
        super
        @guild_id = data['guild_id']
        @action = data['action']
        @rule_id = data['rule_id']
        @rule_trigger_type = data['rule_trigger_type']
        @user_id = data['user_id']
        @channel_id = data['channel_id']
        @message_id = data['message_id']
        @alert_system_message_id = data['alert_system_message_id']
        @content = data['content']
        @matched_keyword = data['matched_keyword']
        @matched_content = data['matched_content']
      end
    end

    class ThreadCreateEvent < BaseEvent
      attr_reader :thread

      def initialize(bot, data)
        super
        @thread = ThreadChannel.new(bot, data)
      end
    end

    class ThreadUpdateEvent < BaseEvent
      attr_reader :thread

      def initialize(bot, data)
        super
        @thread = ThreadChannel.new(bot, data)
      end
    end

    class ThreadDeleteEvent < BaseEvent
      attr_reader :id, :guild_id, :parent_id, :type

      def initialize(bot, data)
        super
        @id = data['id']
        @guild_id = data['guild_id']
        @parent_id = data['parent_id']
        @type = data['type']
      end
    end

    class StageInstanceCreateEvent < BaseEvent
      attr_reader :stage_instance

      def initialize(bot, data)
        super
        @stage_instance = StageInstance.new(bot, data)
      end
    end

    class StageInstanceUpdateEvent < BaseEvent
      attr_reader :stage_instance

      def initialize(bot, data)
        super
        @stage_instance = StageInstance.new(bot, data)
      end
    end

    class StageInstanceDeleteEvent < BaseEvent
      attr_reader :stage_instance

      def initialize(bot, data)
        super
        @stage_instance = StageInstance.new(bot, data)
      end
    end

    class GuildScheduledEventCreateEvent < BaseEvent
      attr_reader :event

      def initialize(bot, data)
        super
        @event = ScheduledEvent.new(bot, data)
      end
    end

    class GuildScheduledEventUpdateEvent < BaseEvent
      attr_reader :event

      def initialize(bot, data)
        super
        @event = ScheduledEvent.new(bot, data)
      end
    end

    class GuildScheduledEventDeleteEvent < BaseEvent
      attr_reader :event

      def initialize(bot, data)
        super
        @event = ScheduledEvent.new(bot, data)
      end
    end

    class EntitlementCreateEvent < BaseEvent
      attr_reader :data

      def initialize(bot, data)
        super
        @data = data
      end
    end

    class EntitlementUpdateEvent < BaseEvent
      attr_reader :data

      def initialize(bot, data)
        super
        @data = data
      end
    end

    class EntitlementDeleteEvent < BaseEvent
      attr_reader :data

      def initialize(bot, data)
        super
        @data = data
      end
    end

    class ApplicationCommandPermissionsUpdateEvent < BaseEvent
      attr_reader :permissions

      def initialize(bot, data)
        super
        @permissions = data
      end
    end

    class ChannelPinsUpdateEvent < BaseEvent
      attr_reader :guild_id, :channel_id, :last_pin_timestamp

      def initialize(bot, data)
        super
        @guild_id = data['guild_id']
        @channel_id = data['channel_id']
        @last_pin_timestamp = data['last_pin_timestamp']
      end
    end

    class GuildJoinRequestUpdateEvent < BaseEvent
      attr_reader :status, :user_id, :guild_id

      def initialize(bot, data)
        super
        @status = data['status']
        @user_id = data['user_id']
        @guild_id = data['guild_id']
      end
    end

    class GuildJoinRequestDeleteEvent < BaseEvent
      attr_reader :id, :user_id, :guild_id

      def initialize(bot, data)
        super
        @id = data['id']
        @user_id = data['user_id']
        @guild_id = data['guild_id']
      end
    end

    class MessagePollVoteAddEvent < BaseEvent
      attr_reader :user_id, :channel_id, :message_id, :guild_id, :answer_id

      def initialize(bot, data)
        super
        @user_id = data['user_id']
        @channel_id = data['channel_id']
        @message_id = data['message_id']
        @guild_id = data['guild_id']
        @answer_id = data['answer_id']
      end
    end

    class MessagePollVoteRemoveEvent < BaseEvent
      attr_reader :user_id, :channel_id, :message_id, :guild_id, :answer_id

      def initialize(bot, data)
        super
        @user_id = data['user_id']
        @channel_id = data['channel_id']
        @message_id = data['message_id']
        @guild_id = data['guild_id']
        @answer_id = data['answer_id']
      end
    end

    class ThreadListSyncEvent < BaseEvent
      attr_reader :guild_id, :channel_ids, :threads, :members

      def initialize(bot, data)
        super
        @guild_id = data['guild_id']
        @channel_ids = data['channel_ids']
        @threads = data['threads'].map { |t| Channel.from_data(bot, t) }
        @members = data['members']
      end
    end

    class ThreadMemberUpdateEvent < BaseEvent
      attr_reader :member

      def initialize(bot, data)
        super
        @member = data
      end
    end

    class ThreadMembersUpdateEvent < BaseEvent
      attr_reader :id, :guild_id, :member_count, :added_members, :removed_member_ids

      def initialize(bot, data)
        super
        @id = data['id']
        @guild_id = data['guild_id']
        @member_count = data['member_count']
        @added_members = data['added_members']
        @removed_member_ids = data['removed_member_ids']
      end
    end

    class VoiceServerUpdateEvent < BaseEvent
      attr_reader :token, :guild_id, :endpoint

      def initialize(bot, data)
        super
        @token = data['token']
        @guild_id = data['guild_id']
        @endpoint = data['endpoint']
      end
    end

    class AuditLogEntryCreateEvent < BaseEvent
      attr_reader :entry

      def initialize(bot, data)
        super
        @entry = AuditLogEntry.new(bot, data)
      end
    end
  end
end
