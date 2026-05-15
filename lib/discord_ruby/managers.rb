module DiscordRuby
  class UserManager < CachedManager
    def fetch(id, force: false)
      return cache[id.to_s] if cache.key?(id.to_s) && !force
      data = @bot.api.fetch_user(id)
      user = User.new(@bot, data)
      cache[id.to_s] = user
      user
    end
  end

  class GuildManager < CachedManager
    def fetch(id, force: false)
      return cache[id.to_s] if cache.key?(id.to_s) && !force
      data = @bot.api.fetch_guild(id)
      guild = Guild.new(@bot, data)
      cache[id.to_s] = guild
      guild
    end

    def create(name, **options)
      data = @bot.api.request(:post, '/guilds', body: {name: name}.merge(options))
      guild = Guild.new(@bot, data)
      cache[guild.id] = guild
      guild
    end
  end

  class ChannelManager < CachedManager
    def fetch(id, force: false)
      return cache[id.to_s] if cache.key?(id.to_s) && !force
      data = @bot.api.fetch_channel(id)
      channel = Channel.from_data(@bot, data)
      cache[id.to_s] = channel
      channel
    end
  end

  class MemberManager < CachedManager
    attr_reader :guild_id

    def initialize(bot, guild_id)
      super(bot)
      @guild_id = guild_id
    end

    def fetch(id, force: false)
      return cache[id.to_s] if cache.key?(id.to_s) && !force
      data = @bot.api.fetch_guild_member(@guild_id, id)
      member = Member.new(@bot, data.merge('guild_id' => @guild_id))
      cache[id.to_s] = member
      member
    end

    def list(limit: 1000, after: nil)
      @bot.api.list_guild_members(@guild_id, limit: limit, after: after).map do |data|
        member = Member.new(@bot, data.merge('guild_id' => @guild_id))
        cache[member.id] = member
        member
      end
    end

    def kick(id, reason: nil)
      @bot.api.remove_guild_member(@guild_id, id, reason: reason)
    end

    def ban(id, delete_message_days: 0, reason: nil)
      @bot.api.create_guild_ban(@guild_id, id, delete_message_days: delete_message_days, reason: reason)
    end

    def unban(id, reason: nil)
      @bot.api.remove_guild_ban(@guild_id, id, reason: reason)
    end
  end

  class RoleManager < CachedManager
    attr_reader :guild_id

    def initialize(bot, guild_id)
      super(bot)
      @guild_id = guild_id
    end

    def fetch_all
      @bot.api.fetch_guild_roles(@guild_id).map do |data|
        role = Role.new(@bot, data.merge('guild_id' => @guild_id))
        cache[role.id] = role
        role
      end
    end

    def create(**options)
      data = @bot.api.create_guild_role(@guild_id, **options)
      role = Role.new(@bot, data.merge('guild_id' => @guild_id))
      cache[role.id] = role
      role
    end
  end

  class EmojiManager < CachedManager
    attr_reader :guild_id

    def initialize(bot, guild_id)
      super(bot)
      @guild_id = guild_id
    end

    def fetch_all
      @bot.api.fetch_guild_emojis(@guild_id).map do |data|
        emoji = Emoji.new(@bot, data.merge('guild_id' => @guild_id))
        cache[emoji.id] = emoji
        emoji
      end
    end

    def create(name, image, **options)
      data = @bot.api.create_guild_emoji(@guild_id, name: name, image: image, **options)
      emoji = Emoji.new(@bot, data.merge('guild_id' => @guild_id))
      cache[emoji.id] = emoji
      emoji
    end
  end

  class StickerManager < CachedManager
    attr_reader :guild_id

    def initialize(bot, guild_id)
      super(bot)
      @guild_id = guild_id
    end

    def fetch_all
      @bot.api.fetch_guild_stickers(@guild_id).map do |data|
        sticker = Sticker.new(@bot, data.merge('guild_id' => @guild_id))
        cache[sticker.id] = sticker
        sticker
      end
    end

    def fetch(id)
      data = @bot.api.fetch_guild_sticker(@guild_id, id)
      sticker = Sticker.new(@bot, data.merge('guild_id' => @guild_id))
      cache[sticker.id] = sticker
      sticker
    end

    def create(name, description, tags, file, **options)
      data = @bot.api.create_guild_sticker(@guild_id, name: name, description: description, tags: tags, file: file, **options)
      sticker = Sticker.new(@bot, data.merge('guild_id' => @guild_id))
      cache[sticker.id] = sticker
      sticker
    end
  end

  class WebhookManager < BaseManager
    def fetch_channel(channel_id)
      @bot.api.fetch_channel_webhooks(channel_id).map { |w| Webhook.new(@bot, w) }
    end

    def fetch_guild(guild_id)
      @bot.api.fetch_guild_webhooks(guild_id).map { |w| Webhook.new(@bot, w) }
    end

    def create(channel_id, name, avatar: nil)
      data = @bot.api.create_webhook(channel_id, name: name, avatar: avatar)
      Webhook.new(@bot, data)
    end
  end

  class InviteManager < BaseManager
    def fetch(code, **options)
      data = @bot.api.fetch_invite(code, **options)
      Invite.new(@bot, data)
    end

    def delete(code)
      @bot.api.delete_invite(code)
    end
  end

  class AutoModerationManager < CachedManager
    attr_reader :guild_id

    def initialize(bot, guild_id)
      super(bot)
      @guild_id = guild_id
    end

    def fetch_all
      @bot.api.fetch_guild_auto_moderation_rules(@guild_id).map do |data|
        rule = AutoModerationRule.new(@bot, data)
        cache[rule.id] = rule
        rule
      end
    end

    def create(**options)
      data = @bot.api.create_guild_auto_moderation_rule(@guild_id, **options)
      rule = AutoModerationRule.new(@bot, data)
      cache[rule.id] = rule
      rule
    end
  end

  class ScheduledEventManager < CachedManager
    attr_reader :guild_id

    def initialize(bot, guild_id)
      super(bot)
      @guild_id = guild_id
    end

    def fetch_all(with_user_count: false)
      @bot.api.fetch_guild_scheduled_events(@guild_id, with_user_count: with_user_count).map do |data|
        event = ScheduledEvent.new(@bot, data)
        cache[event.id] = event
        event
      end
    end

    def create(**options)
      data = @bot.api.create_guild_scheduled_event(@guild_id, **options)
      event = ScheduledEvent.new(@bot, data)
      cache[event.id] = event
      event
    end
  end

  class StageInstanceManager < CachedManager
    attr_reader :guild_id

    def initialize(bot, guild_id)
      super(bot)
      @guild_id = guild_id
    end

    def create(channel_id, topic, privacy_level: 2, send_start_notification: false)
      data = @bot.api.create_stage_instance(channel_id, topic: topic, privacy_level: privacy_level, send_start_notification: send_start_notification)
      instance = StageInstance.new(@bot, data)
      cache[instance.id] = instance
      instance
    end

    def fetch(channel_id)
      data = @bot.api.fetch_stage_instance(channel_id)
      instance = StageInstance.new(@bot, data)
      cache[instance.id] = instance
      instance
    end
  end
end
