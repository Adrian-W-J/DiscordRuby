module DiscordRuby
  class Guild < BaseModel
    attr_reader :name, :icon, :icon_hash, :splash, :discovery_splash, :owner, :owner_id, :permissions, :region, :afk_channel_id, :afk_timeout, :widget_enabled, :widget_channel_id, :verification_level, :default_message_notifications, :explicit_content_filter, :roles, :emojis, :features, :mfa_level, :application_id, :system_channel_id, :system_channel_flags, :rules_channel_id, :max_presences, :max_members, :vanity_url_code, :description, :banner, :premium_tier, :premium_subscription_count, :preferred_locale, :public_updates_channel_id, :max_video_channel_users, :max_stage_video_channel_users, :approximate_member_count, :approximate_presence_count, :welcome_screen, :nsfw_level, :stickers, :premium_progress_bar_enabled, :safety_alerts_channel_id

    def initialize(bot, data)
      super
      @roles = data['roles']&.map { |r| Role.new(bot, r.merge('guild_id' => id)) } || []
      @emojis = data['emojis']&.map { |e| Emoji.new(bot, e.merge('guild_id' => id)) } || []
      @stickers = data['stickers']&.map { |s| Sticker.new(bot, s.merge('guild_id' => id)) } || []
    end

    def icon_url(size: 1024, format: nil)
      return nil unless @icon
      format ||= @icon.start_with?('a_') ? 'gif' : 'png'
      "https://cdn.discordapp.com/icons/#{id}/#{@icon}.#{format}?size=#{size}"
    end

    def splash_url(size: 1024, format: 'png')
      return nil unless @splash
      "https://cdn.discordapp.com/splashes/#{id}/#{@splash}.#{format}?size=#{size}"
    end

    def discovery_splash_url(size: 1024, format: 'png')
      return nil unless @discovery_splash
      "https://cdn.discordapp.com/discovery-splashes/#{id}/#{@discovery_splash}.#{format}?size=#{size}"
    end

    def banner_url(size: 1024, format: 'png')
      return nil unless @banner
      "https://cdn.discordapp.com/banners/#{id}/#{@banner}.#{format}?size=#{size}"
    end

    def fetch_members(limit: 1000, after: nil)
      @bot.api.list_guild_members(id, limit: limit, after: after).map { |m| Member.new(@bot, m.merge('guild_id' => id)) }
    end

    def fetch_member(user_id)
      data = @bot.api.fetch_guild_member(id, user_id)
      Member.new(@bot, data.merge('guild_id' => id))
    end

    def fetch_channels
      @bot.api.fetch_guild_channels(id).map { |c| Channel.from_data(@bot, c) }
    end

    def create_channel(name, type: 0, **options)
      data = @bot.api.create_guild_channel(id, name, type, **options)
      Channel.from_data(@bot, data)
    end

    def fetch_roles
      @bot.api.fetch_guild_roles(id).map { |r| Role.new(@bot, r.merge('guild_id' => id)) }
    end

    def create_role(**options)
      data = @bot.api.create_guild_role(id, **options)
      Role.new(@bot, data.merge('guild_id' => id))
    end

    def fetch_invites
      @bot.api.fetch_guild_invites(id).map { |i| Invite.new(@bot, i) }
    end

    def fetch_webhooks
      @bot.api.fetch_guild_webhooks(id).map { |w| Webhook.new(@bot, w) }
    end

    def fetch_audit_logs(**params)
      @bot.api.fetch_guild_audit_log(id, **params)
    end

    def leave
      @bot.api.leave_guild(id)
    end

    def delete
      @bot.api.delete_guild(id)
    end

    def edit(**options)
      data = @bot.api.edit_guild(id, **options)
      update_data(data)
      self
    end

    def ban(user_id, delete_message_days: 0, reason: nil)
      @bot.api.create_guild_ban(id, user_id, delete_message_days: delete_message_days, reason: reason)
    end

    def unban(user_id, reason: nil)
      @bot.api.remove_guild_ban(id, user_id, reason: reason)
    end

    def kick(user_id, reason: nil)
      @bot.api.remove_guild_member(id, user_id, reason: reason)
    end

    def fetch_bans(limit: 1000, before: nil, after: nil)
      @bot.api.request(:get, "/guilds/#{id}/bans", params: {limit: limit, before: before, after: after})
    end

    def fetch_ban(user_id)
      @bot.api.request(:get, "/guilds/#{id}/bans/#{user_id}")
    end

    def prune(days: 7, compute_prune_count: true, include_roles: [], reason: nil)
      @bot.api.begin_guild_prune(id, days: days, compute_prune_count: compute_prune_count, include_roles: include_roles, reason: reason)
    end

    def fetch_vanity_url
      @bot.api.fetch_guild_vanity_url(id)
    end

    def fetch_widget_settings
      @bot.api.fetch_guild_widget_settings(id)
    end

    def edit_widget_settings(**options)
      @bot.api.edit_guild_widget_settings(id, **options)
    end

    def fetch_widget
      @bot.api.fetch_guild_widget(id)
    end

    def fetch_welcome_screen
      @bot.api.fetch_guild_welcome_screen(id)
    end

    def edit_welcome_screen(**options)
      @bot.api.edit_guild_welcome_screen(id, **options)
    end

    def fetch_onboarding
      @bot.api.fetch_guild_onboarding(id)
    end

    def edit_onboarding(**options)
      @bot.api.edit_guild_onboarding(id, **options)
    end

    def members
      @members ||= Managers::GuildMemberManager.new(@bot, id)
    end

    def roles_manager
      @roles_manager ||= Managers::RoleManager.new(@bot, id)
    end

    def channels_manager
      @channels_manager ||= Managers::ChannelManager.new(@bot, id)
    end

    def emojis_manager
      @emojis_manager ||= Managers::EmojiManager.new(@bot, id)
    end

    def stickers_manager
      @stickers_manager ||= Managers::StickerManager.new(@bot, id)
    end

    def scheduled_events
      @scheduled_events ||= Managers::GuildScheduledEventManager.new(@bot, id)
    end

    def auto_moderation
      @auto_moderation ||= Managers::AutoModerationManager.new(@bot, id)
    end

    def bans
      @bans ||= Managers::BanManager.new(@bot, id)
    end

    def invites_manager
      @invites_manager ||= Managers::InviteManager.new(@bot, guild_id: id)
    end

    def voice_states
      @voice_states ||= Managers::VoiceStateManager.new(@bot, id)
    end

    def onboarding
      @onboarding_manager ||= Managers::OnboardingManager.new(@bot, id)
    end

    def me
      members.fetch('@me')
    end

    def system_channel
      @bot.channels.cache[@system_channel_id] if @system_channel_id
    end

    def rules_channel
      @bot.channels.cache[@rules_channel_id] if @rules_channel_id
    end

    def public_updates_channel
      @bot.channels.cache[@public_updates_channel_id] if @public_updates_channel_id
    end

    def afk_channel
      @bot.channels.cache[@afk_channel_id] if @afk_channel_id
    end

    def widget_channel
      @bot.channels.cache[@widget_channel_id] if @widget_channel_id
    end

    def safety_alerts_channel
      @bot.channels.cache[@safety_alerts_channel_id] if @safety_alerts_channel_id
    end

    def owner
      @bot.users.cache[@owner_id] || @bot.users.fetch(@owner_id)
    end

    def premium_tier_name
      case @premium_tier
      when 0 then 'None'
      when 1 then 'Tier 1'
      when 2 then 'Tier 2'
      when 3 then 'Tier 3'
      else 'Unknown'
      end
    end

    def nsfw_level_name
      case @nsfw_level
      when 0 then 'Default'
      when 1 then 'Explicit'
      when 2 then 'Safe'
      when 3 then 'Age Restricted'
      else 'Unknown'
      end
    end

    def verification_level_name
      case @verification_level
      when 0 then 'None'
      when 1 then 'Low'
      when 2 then 'Medium'
      when 3 then 'High'
      when 4 then 'Very High'
      else 'Unknown'
      end
    end

    def explicit_content_filter_name
      case @explicit_content_filter
      when 0 then 'Disabled'
      when 1 then 'Members Without Roles'
      when 2 then 'All Members'
      else 'Unknown'
      end
    end

    def mfa_level_name
      case @mfa_level
      when 0 then 'None'
      when 1 then 'Elevated'
      else 'Unknown'
      end
    end
  end
end
