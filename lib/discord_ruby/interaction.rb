module DiscordRuby
  module Interaction
    module ResponseType
      PONG = 1
      CHANNEL_MESSAGE_WITH_SOURCE = 4
      DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE = 5
      DEFERRED_UPDATE_MESSAGE = 6
      UPDATE_MESSAGE = 7
      APPLICATION_COMMAND_AUTOCOMPLETE_RESULT = 8
      MODAL = 9
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
    end

    module ButtonStyle
      PRIMARY = 1
      SECONDARY = 2
      SUCCESS = 3
      DANGER = 4
      LINK = 5
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
end
