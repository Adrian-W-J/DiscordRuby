module DiscordRuby
  class Bitfield
    attr_reader :bitfield

    def initialize(bitfield = 0)
      @bitfield = bitfield.to_i

    end

    def self.flags
      {}
    end

    def has?(*flags)
      flags.all? do |flag|
        bit = self.class.flags[flag.to_sym]
        raise ArgumentError, "Unknown flag: #{flag}" unless bit
        (@bitfield & bit) == bit
      end
    end

    def add(*flags)
      flags.each do |flag|
        bit = self.class.flags[flag.to_sym]
        raise ArgumentError, "Unknown flag: #{flag}" unless bit
        @bitfield |= bit
      end
      self
    end

    def remove(*flags)
      flags.each do |flag|
        bit = self.class.flags[flag.to_sym]
        raise ArgumentError, "Unknown flag: #{flag}" unless bit
        @bitfield &= ~bit
      end
      self
    end

    def to_a
      self.class.flags.select { |name, bit| (@bitfield & bit) == bit }.keys
    end

    def to_i
      @bitfield
    end

    def inspect
      "#<#{self.class} bitfield=#{@bitfield} flags=#{to_a}>"
    end
  end

  class Permissions < Bitfield
    FLAGS = {
      create_instant_invite: 1 << 0,
      kick_members: 1 << 1,
      ban_members: 1 << 2,
      administrator: 1 << 3,
      manage_channels: 1 << 4,
      manage_guild: 1 << 5,
      add_reactions: 1 << 6,
      view_audit_log: 1 << 7,
      priority_speaker: 1 << 8,
      stream: 1 << 9,
      view_channel: 1 << 10,
      send_messages: 1 << 11,
      send_tts_messages: 1 << 12,
      manage_messages: 1 << 13,
      embed_links: 1 << 14,
      attach_files: 1 << 15,
      read_message_history: 1 << 16,
      mention_everyone: 1 << 17,
      use_external_emojis: 1 << 18,
      view_guild_insights: 1 << 19,
      connect: 1 << 20,
      speak: 1 << 21,
      mute_members: 1 << 22,
      deafen_members: 1 << 23,
      move_members: 1 << 24,
      use_vad: 1 << 25,
      change_nickname: 1 << 26,
      manage_nicknames: 1 << 27,
      manage_roles: 1 << 28,
      manage_webhooks: 1 << 29,
      manage_emojis_and_stickers: 1 << 30,
      use_application_commands: 1 << 31,
      request_to_speak: 1 << 32,
      manage_events: 1 << 33,
      manage_threads: 1 << 34,
      create_public_threads: 1 << 35,
      create_private_threads: 1 << 36,
      use_external_stickers: 1 << 37,
      send_messages_in_threads: 1 << 38,
      use_embedded_activities: 1 << 39,
      moderate_members: 1 << 40,
      view_creator_monetization_analytics: 1 << 41,
      use_soundboard: 1 << 42,
      use_external_sounds: 1 << 45,
      send_voice_messages: 1 << 46
    }.freeze

    def self.flags
      FLAGS
    end
  end

  class UserFlags < Bitfield
    FLAGS = {
      staff: 1 << 0,
      partner: 1 << 1,
      hypesquad: 1 << 2,
      bug_hunter_level_1: 1 << 3,
      mfa_sms: 1 << 4,
      premium_promo_dismissed: 1 << 5,
      hypesquad_online_house_1: 1 << 6,
      hypesquad_online_house_2: 1 << 7,
      hypesquad_online_house_3: 1 << 8,
      premium_early_supporter: 1 << 9,
      team_pseudo_user: 1 << 10,
      has_unused_gratuitous_premium_status: 1 << 11,
      bug_hunter_level_2: 1 << 14,
      verified_bot: 1 << 16,
      verified_developer: 1 << 17,
      certified_moderator: 1 << 18,
      bot_http_interactions: 1 << 19,
      active_developer: 1 << 22
    }.freeze

    def self.flags
      FLAGS
    end
  end

  class MessageFlags < Bitfield
    FLAGS = {
      crossposted: 1 << 0,
      is_crosspost: 1 << 1,
      suppress_embeds: 1 << 2,
      source_message_deleted: 1 << 3,
      urgent: 1 << 4,
      has_thread: 1 << 5,
      ephemeral: 1 << 6,
      loading: 1 << 7,
      failed_to_mention_some_roles_in_thread: 1 << 8,
      suppress_notifications: 1 << 12,
      is_voice_message: 1 << 13
    }.freeze

    def self.flags
      FLAGS
    end
  end

  class GuildFlags < Bitfield
    FLAGS = {
      invites_disabled: 1 << 0,
      premium_progress_bar_enabled: 1 << 1,
      role_subscriptions_available_for_purchase: 1 << 2,
      role_subscriptions_enabled: 1 << 3,
      guild_onboarding_has_prompts: 1 << 4,
      guild_onboarding_has_responses: 1 << 5
    }.freeze

    def self.flags
      FLAGS
    end
  end

  class ChannelFlags < Bitfield
    FLAGS = {
      pinned: 1 << 1,
      require_tag: 1 << 4,
      is_spam: 1 << 5
    }.freeze

    def self.flags
      FLAGS
    end
  end

  class ActivityFlags < Bitfield
    FLAGS = {
      instance: 1 << 0,
      join: 1 << 1,
      spectate: 1 << 2,
      join_request: 1 << 3,
      sync: 1 << 4,
      play: 1 << 5,
      party_privacy_friends: 1 << 6,
      party_privacy_voice_channel: 1 << 7,
      embedded: 1 << 8
    }.freeze

    def self.flags
      FLAGS
    end
  end

  class ApplicationFlags < Bitfield
    FLAGS = {
      embedded_released: 1 << 1,
      managed_emoji: 1 << 2,
      group_dm_create: 1 << 3,
      rpc_has_connected: 1 << 11,
      gateway_presence: 1 << 12,
      gateway_presence_limited: 1 << 13,
      gateway_guild_members: 1 << 14,
      gateway_guild_members_limited: 1 << 15,
      verification_pending_guild_limit: 1 << 16,
      embedded: 1 << 17,
      gateway_message_content: 1 << 18,
      gateway_message_content_limited: 1 << 19,
      embedded_first_party: 1 << 20,
      application_command_badge: 1 << 23,
      active_developer: 1 << 25
    }.freeze

    def self.flags
      FLAGS
    end
  end

  class GuildSystemChannelFlags < Bitfield
    FLAGS = {
      suppress_join_notifications: 1 << 0,
      suppress_premium_subscriptions: 1 << 1,
      suppress_guild_reminder_notifications: 1 << 2,
      suppress_join_notification_replies: 1 << 3,
      suppress_role_subscription_purchase_notifications: 1 << 4,
      suppress_role_subscription_purchase_notification_replies: 1 << 5
    }.freeze

    def self.flags
      FLAGS
    end
  end

  class Intents < Bitfield
    FLAGS = {
      guilds: 1 << 0,
      guild_members: 1 << 1,
      guild_moderation: 1 << 2,
      guild_emojis_and_stickers: 1 << 3,
      guild_integrations: 1 << 4,
      guild_webhooks: 1 << 5,
      guild_invites: 1 << 6,
      guild_voice_states: 1 << 7,
      guild_presences: 1 << 8,
      guild_messages: 1 << 9,
      guild_message_reactions: 1 << 10,
      guild_message_typing: 1 << 11,
      direct_messages: 1 << 12,
      direct_message_reactions: 1 << 13,
      direct_message_typing: 1 << 14,
      message_content: 1 << 15,
      guild_scheduled_events: 1 << 16,
      auto_moderation_configuration: 1 << 20,
      auto_moderation_execution: 1 << 21
    }.freeze

    def self.flags
      FLAGS
    end
  end

  class MemberFlags < Bitfield
    FLAGS = {
      did_rejoin: 1 << 0,
      completed_onboarding: 1 << 1,
      bypasses_verification: 1 << 2,
      started_onboarding: 1 << 3
    }.freeze

    def self.flags
      FLAGS
    end
  end
end
