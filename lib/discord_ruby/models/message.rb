module DiscordRuby
  class Message < BaseModel
    attr_reader :channel_id, :guild_id, :author, :member, :content, :timestamp, :edited_timestamp, :tts, :mention_everyone, :mentions, :mention_roles, :mention_channels, :attachments, :embeds, :reactions, :nonce, :pinned, :webhook_id, :type, :activity, :application, :application_id, :message_reference, :flags, :referenced_message, :interaction, :thread, :components, :sticker_items, :stickers, :position, :role_subscription_data, :resolved

    def initialize(bot, data)
      super
      @author = User.new(bot, data['author']) if data['author']
      @member = Member.new(bot, data['member'].merge('guild_id' => data['guild_id'], 'user' => data['author'])) if data['member'] && data['author']
      @attachments = data['attachments']&.map { |a| Attachment.new(bot, a) } || []
      @embeds = data['embeds']&.map { |e| Embed.new(bot, e) } || []
      @reactions = data['reactions']&.map { |r| Reaction.new(bot, r) } || []
      @mentions = data['mentions']&.map { |u| User.new(bot, u) } || []
      @mention_roles = data['mention_roles'] || []
      @sticker_items = data['sticker_items'] || []
    end

    def reply(content = nil, **options, &block)
      @bot.send_message(@channel_id, content, message_reference: {message_id: id}, **options, &block)
    end

    def edit(content = nil, **options, &block)
      data = @bot.api.edit_message(@channel_id, id, content: content, **options, &block)
      update_data(data)
      self
    end

    def delete(reason: nil)
      @bot.api.delete_message(@channel_id, id)
    end

    def react(emoji)
      @bot.api.add_reaction(@channel_id, id, emoji)
    end

    alias_method :add_reaction, :react

    def remove_reaction(emoji, user_id = '@me')
      @bot.api.remove_reaction(@channel_id, id, emoji, user_id)
    end

    def clear_reactions
      @bot.api.clear_reactions(@channel_id, id)
    end

    def pin
      @bot.api.pin_message(@channel_id, id)
    end

    def unpin
      @bot.api.unpin_message(@channel_id, id)
    end

    def crosspost
      @bot.api.crosspost_message(@channel_id, id)
    end

    def start_thread(name, **options)
      data = @bot.api.start_thread_from_message(@channel_id, id, name: name, **options)
      ThreadChannel.new(@bot, data)
    end

    def channel
      @bot.channels.cache[@channel_id] || @bot.api.fetch_channel(@channel_id)
    end

    def guild
      @bot.guilds.cache[@guild_id] if @guild_id
    end

    def url
      "https://discord.com/channels/#{@guild_id || '@me'}/#{@channel_id}/#{id}"
    end

    def system?
      @type != 0 && @type != 19 && @type != 20
    end

    def editable?
      @author&.id == @bot.user.id
    end

    def deletable?
      return true if editable?
      guild&.me&.permissions&.has?(:manage_messages)
    end

    def pinnable?
      guild&.me&.permissions&.has?(:manage_messages)
    end

    def flags_bitfield
      @flags_bitfield ||= MessageFlags.new(@flags || 0)
    end

    def ephemeral?
      flags_bitfield.has?(:ephemeral)
    end

    def webhook?
      !!@webhook_id
    end

    def interaction?
      !!@interaction
    end

    def thread?
      !!@thread
    end

    def guild?
      !!@guild_id
    end

    def reactions_manager
      @reactions_manager ||= Managers::ReactionManager.new(@bot, @channel_id, id)
    end

    def ==(other)
      other.is_a?(Message) && id == other.id
    end
  end
end
