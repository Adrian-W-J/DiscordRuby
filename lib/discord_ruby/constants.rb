module DiscordRuby
  module Constants
    module Permissions
      CREATE_INSTANT_INVITE = 1 << 0
      KICK_MEMBERS = 1 << 1
      BAN_MEMBERS = 1 << 2
      ADMINISTRATOR = 1 << 3
      MANAGE_CHANNELS = 1 << 4
      MANAGE_GUILD = 1 << 5
      ADD_REACTIONS = 1 << 6
      VIEW_AUDIT_LOG = 1 << 7
      PRIORITY_SPEAKER = 1 << 8
      STREAM = 1 << 9
      VIEW_CHANNEL = 1 << 10
      SEND_MESSAGES = 1 << 11
      SEND_TTS_MESSAGES = 1 << 12
      MANAGE_MESSAGES = 1 << 13
      EMBED_LINKS = 1 << 14
      ATTACH_FILES = 1 << 15
      READ_MESSAGE_HISTORY = 1 << 16
      MENTION_EVERYONE = 1 << 17
      USE_EXTERNAL_EMOJIS = 1 << 18
      VIEW_GUILD_INSIGHTS = 1 << 19
      CONNECT = 1 << 20
      SPEAK = 1 << 21
      MUTE_MEMBERS = 1 << 22
      DEAFEN_MEMBERS = 1 << 23
      MOVE_MEMBERS = 1 << 24
      USE_VAD = 1 << 25
      CHANGE_NICKNAME = 1 << 26
      MANAGE_NICKNAMES = 1 << 27
      MANAGE_ROLES = 1 << 28
      MANAGE_WEBHOOKS = 1 << 29
      MANAGE_GUILD_EXPRESSIONS = 1 << 30
      USE_APPLICATION_COMMANDS = 1 << 31
      REQUEST_TO_SPEAK = 1 << 32
      MANAGE_EVENTS = 1 << 33
      MANAGE_THREADS = 1 << 34
      CREATE_PUBLIC_THREADS = 1 << 35
      CREATE_PRIVATE_THREADS = 1 << 36
      USE_EXTERNAL_STICKERS = 1 << 37
      SEND_MESSAGES_IN_THREADS = 1 << 38
      USE_EMBEDDED_ACTIVITIES = 1 << 39
      MODERATE_MEMBERS = 1 << 40
      VIEW_CREATOR_MONETIZATION_ANALYTICS = 1 << 41
      USE_SOUNDBOARD = 1 << 42
      USE_EXTERNAL_SOUNDS = 1 << 45
      SEND_VOICE_MESSAGES = 1 << 46
    end

    module Intents
      GUILDS = 1 << 0
      GUILD_MEMBERS = 1 << 1
      GUILD_MODERATION = 1 << 2
      GUILD_EMOJIS_AND_STICKERS = 1 << 3
      GUILD_INTEGRATIONS = 1 << 4
      GUILD_WEBHOOKS = 1 << 5
      GUILD_INVITES = 1 << 6
      GUILD_VOICE_STATES = 1 << 7
      GUILD_PRESENCES = 1 << 8
      GUILD_MESSAGES = 1 << 9
      GUILD_MESSAGE_REACTIONS = 1 << 10
      GUILD_MESSAGE_TYPING = 1 << 11
      DIRECT_MESSAGES = 1 << 12
      DIRECT_MESSAGE_REACTIONS = 1 << 13
      DIRECT_MESSAGE_TYPING = 1 << 14
      MESSAGE_CONTENT = 1 << 15
      GUILD_SCHEDULED_EVENTS = 1 << 16
      AUTO_MODERATION_CONFIGURATION = 1 << 20
      AUTO_MODERATION_EXECUTION = 1 << 21
    end

    module ChannelTypes
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

    module MessageTypes
      DEFAULT = 0
      RECIPIENT_ADD = 1
      RECIPIENT_REMOVE = 2
      CALL = 3
      CHANNEL_NAME_CHANGE = 4
      CHANNEL_ICON_CHANGE = 5
      CHANNEL_PINNED_MESSAGE = 6
      USER_JOIN = 7
      GUILD_BOOST = 8
      GUILD_BOOST_TIER_1 = 9
      GUILD_BOOST_TIER_2 = 10
      GUILD_BOOST_TIER_3 = 11
      CHANNEL_FOLLOW_ADD = 12
      GUILD_DISCOVERY_DISQUALIFIED = 14
      GUILD_DISCOVERY_REQUALIFIED = 15
      GUILD_DISCOVERY_GRACE_PERIOD_INITIAL_WARNING = 16
      GUILD_DISCOVERY_GRACE_PERIOD_FINAL_WARNING = 17
      THREAD_CREATED = 18
      REPLY = 19
      CHAT_INPUT_COMMAND = 20
      THREAD_STARTER_MESSAGE = 21
      GUILD_INVITE_REMINDER = 22
      CONTEXT_MENU_COMMAND = 23
      AUTO_MODERATION_ACTION = 24
      ROLE_SUBSCRIPTION_PURCHASE = 25
      INTERACTION_PREMIUM_UPSELL = 26
      STAGE_START = 27
      STAGE_END = 28
      STAGE_SPEAKER = 29
      STAGE_TOPIC = 31
      GUILD_APPLICATION_PREMIUM_SUBSCRIPTION = 32
    end

    module ActivityTypes
      PLAYING = 0
      STREAMING = 1
      LISTENING = 2
      WATCHING = 3
      CUSTOM = 4
      COMPETING = 5
    end

    module StatusTypes
      ONLINE = 'online'
      DND = 'dnd'
      IDLE = 'idle'
      INVISIBLE = 'invisible'
      OFFLINE = 'offline'
    end

    module InteractionTypes
      PING = 1
      APPLICATION_COMMAND = 2
      MESSAGE_COMPONENT = 3
      APPLICATION_COMMAND_AUTOCOMPLETE = 4
      MODAL_SUBMIT = 5
    end

    module InteractionResponseTypes
      PONG = 1
      CHANNEL_MESSAGE_WITH_SOURCE = 4
      DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE = 5
      DEFERRED_UPDATE_MESSAGE = 6
      UPDATE_MESSAGE = 7
      APPLICATION_COMMAND_AUTOCOMPLETE_RESULT = 8
      MODAL = 9
      PREMIUM_UPSELL = 10
    end

    module ComponentTypes
      ACTION_ROW = 1
      BUTTON = 2
      STRING_SELECT = 3
      TEXT_INPUT = 4
      USER_SELECT = 5
      ROLE_SELECT = 6
      MENTIONABLE_SELECT = 7
      CHANNEL_SELECT = 8
    end

    module ButtonStyles
      PRIMARY = 1
      SECONDARY = 2
      SUCCESS = 3
      DANGER = 4
      LINK = 5
    end

    module TextInputStyles
      SHORT = 1
      PARAGRAPH = 2
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

    module Colors
      DEFAULT = 0x000000
      WHITE = 0xFFFFFF
      AQUA = 0x1ABC9C
      GREEN = 0x2ECC71
      BLUE = 0x3498DB
      YELLOW = 0xFFFF00
      PURPLE = 0x9B59B6
      LUMINOUS_VIVID_PINK = 0xE91E63
      FUCHSIA = 0xEB459E
      GOLD = 0xF1C40F
      ORANGE = 0xE67E22
      RED = 0xE74C3C
      GREY = 0x95A5A6
      NAVY = 0x34495E
      DARK_AQUA = 0x11806A
      DARK_GREEN = 0x1F8B4C
      DARK_BLUE = 0x206694
      DARK_PURPLE = 0x71368A
      DARK_VIVID_PINK = 0xAD1457
      DARK_GOLD = 0xC27C0E
      DARK_ORANGE = 0xA84300
      DARK_RED = 0x992D22
      DARK_GREY = 0x979C9F
      DARKER_GREY = 0x7F8C8D
      LIGHT_GREY = 0xBCC0C0
      DARK_NAVY = 0x2C3E50
      BLURPLE = 0x5865F2
      GREYPLE = 0x99AAB5
      DARK_BUT_NOT_BLACK = 0x2C2F33
      NOT_QUITE_BLACK = 0x23272A
    end

    module ApplicationFlags
      APPLICATION_AUTO_MODERATION_RULE_CREATE_V2 = 1 << 6
      GATEWAY_PRESENCE = 1 << 12
      GATEWAY_PRESENCE_LIMITED = 1 << 13
      GATEWAY_GUILD_MEMBERS = 1 << 14
      GATEWAY_GUILD_MEMBERS_LIMITED = 1 << 15
      VERIFICATION_PENDING_GUILD_LIMIT = 1 << 16
      EMBEDDED = 1 << 17
      GATEWAY_MESSAGE_CONTENT = 1 << 18
      GATEWAY_MESSAGE_CONTENT_LIMITED = 1 << 19
      APPLICATION_COMMAND_BADGE = 1 << 23
    end

    module ApplicationCommandTypes
      CHAT_INPUT = 1
      USER = 2
      MESSAGE = 3
    end

    module ApplicationCommandOptionTypes
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

    module ApplicationCommandPermissionTypes
      ROLE = 1
      USER = 2
      CHANNEL = 3
    end

    module OverwriteTypes
      ROLE = 0
      MEMBER = 1
    end

    module VideoQualityModes
      AUTO = 1
      FULL = 2
    end

    module ThreadAutoArchiveDurations
      ONE_HOUR = 60
      ONE_DAY = 1440
      THREE_DAYS = 4320
      ONE_WEEK = 10080
    end

    module GuildVerificationLevels
      NONE = 0
      LOW = 1
      MEDIUM = 2
      HIGH = 3
      VERY_HIGH = 4
    end

    module GuildDefaultMessageNotifications
      ALL_MESSAGES = 0
      ONLY_MENTIONS = 1
    end

    module GuildExplicitContentFilterLevels
      DISABLED = 0
      MEMBERS_WITHOUT_ROLES = 1
      ALL_MEMBERS = 2
    end

    module GuildMFALevels
      NONE = 0
      ELEVATED = 1
    end

    module GuildSystemChannelFlags
      SUPPRESS_JOIN_NOTIFICATIONS = 1 << 0
      SUPPRESS_PREMIUM_SUBSCRIPTIONS = 1 << 1
      SUPPRESS_GUILD_REMINDER_NOTIFICATIONS = 1 << 2
      SUPPRESS_JOIN_NOTIFICATION_REPLIES = 1 << 3
      SUPPRESS_ROLE_SUBSCRIPTION_PURCHASE_NOTIFICATIONS = 1 << 4
      SUPPRESS_ROLE_SUBSCRIPTION_PURCHASE_NOTIFICATION_REPLIES = 1 << 5
    end

    module GuildPremiumTiers
      NONE = 0
      TIER_1 = 1
      TIER_2 = 2
      TIER_3 = 3
    end

    module GuildHubTypes
      DEFAULT = 0
      HIGH_SCHOOL = 1
      COLLEGE = 2
    end

    module GuildNSFWLevels
      DEFAULT = 0
      EXPLICIT = 1
      SAFE = 2
      AGE_RESTRICTED = 3
    end

    module InviteTargetTypes
      STREAM = 1
      EMBEDDED_APPLICATION = 2
    end

    module PrivacyLevels
      PUBLIC = 1
      GUILD_ONLY = 2
    end

    module GuildScheduledEventStatus
      SCHEDULED = 1
      ACTIVE = 2
      COMPLETED = 3
      CANCELED = 4
    end

    module GuildScheduledEventEntityTypes
      STAGE_INSTANCE = 1
      VOICE = 2
      EXTERNAL = 3
    end

    module AutoModerationTriggerTypes
      KEYWORD = 1
      SPAM = 3
      KEYWORD_PRESET = 4
      MENTION_SPAM = 5
    end

    module AutoModerationKeywordPresetTypes
      PROFANITY = 1
      SEXUAL_CONTENT = 2
      SLURS = 3
    end

    module AutoModerationEventTypes
      MESSAGE_SEND = 1
    end

    module AutoModerationActionTypes
      BLOCK_MESSAGE = 1
      SEND_ALERT_MESSAGE = 2
      TIMEOUT = 3
    end

    module StickerTypes
      STANDARD = 1
      GUILD = 2
    end

    module StickerFormatTypes
      PNG = 1
      APNG = 2
      LOTTIE = 3
      GIF = 4
    end

    module AuditLogActions
      GUILD_UPDATE = 1
      CHANNEL_CREATE = 10
      CHANNEL_UPDATE = 11
      CHANNEL_DELETE = 12
      CHANNEL_OVERWRITE_CREATE = 13
      CHANNEL_OVERWRITE_UPDATE = 14
      CHANNEL_OVERWRITE_DELETE = 15
      MEMBER_KICK = 20
      MEMBER_PRUNE = 21
      MEMBER_BAN_ADD = 22
      MEMBER_BAN_REMOVE = 23
      MEMBER_UPDATE = 24
      MEMBER_ROLE_UPDATE = 25
      MEMBER_MOVE = 26
      MEMBER_DISCONNECT = 27
      BOT_ADD = 28
      ROLE_CREATE = 30
      ROLE_UPDATE = 31
      ROLE_DELETE = 32
      INVITE_CREATE = 40
      INVITE_UPDATE = 41
      INVITE_DELETE = 42
      WEBHOOK_CREATE = 50
      WEBHOOK_UPDATE = 51
      WEBHOOK_DELETE = 52
      EMOJI_CREATE = 60
      EMOJI_UPDATE = 61
      EMOJI_DELETE = 62
      MESSAGE_DELETE = 72
      MESSAGE_BULK_DELETE = 73
      MESSAGE_PIN = 74
      MESSAGE_UNPIN = 75
      INTEGRATION_CREATE = 80
      INTEGRATION_UPDATE = 81
      INTEGRATION_DELETE = 82
      STAGE_INSTANCE_CREATE = 83
      STAGE_INSTANCE_UPDATE = 84
      STAGE_INSTANCE_DELETE = 85
      STICKER_CREATE = 90
      STICKER_UPDATE = 91
      STICKER_DELETE = 92
      GUILD_SCHEDULED_EVENT_CREATE = 100
      GUILD_SCHEDULED_EVENT_UPDATE = 101
      GUILD_SCHEDULED_EVENT_DELETE = 102
      THREAD_CREATE = 110
      THREAD_UPDATE = 111
      THREAD_DELETE = 112
      APPLICATION_COMMAND_PERMISSION_UPDATE = 121
      AUTO_MODERATION_RULE_CREATE = 140
      AUTO_MODERATION_RULE_UPDATE = 141
      AUTO_MODERATION_RULE_DELETE = 142
      AUTO_MODERATION_BLOCK_MESSAGE = 143
      AUTO_MODERATION_FLAG_TO_CHANNEL = 144
      AUTO_MODERATION_USER_COMMUNICATION_DISABLED = 145
      CREATOR_MONETIZATION_REQUEST_CREATED = 150
      CREATOR_MONETIZATION_TERMS_ACCEPTED = 151
    end
  end
end
