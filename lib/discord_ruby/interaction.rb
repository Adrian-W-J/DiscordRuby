module DiscordRuby
  module Interaction
    module ResponseType
      PONG = 1
      CHANNEL_MESSAGE_WITH_SOURCE = 4
      DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE = 5
      DEFERRED_UPDATE_MESSAGE = 6
      UPDATE_MESSAGE = 7
    end

    module InteractionType
      PING = 1
      APPLICATION_COMMAND = 2
      MESSAGE_COMPONENT = 3
      APPLICATION_COMMAND_AUTOCOMPLETE = 4
      MODAL_SUBMIT = 5
    end

    module ComponentType
      ACTION_ROW = 1
      BUTTON = 2
      STRING_SELECT = 3
      TEXT_INPUT = 4
    end

    module ButtonStyle
      PRIMARY = 1
      SECONDARY = 2
      SUCCESS = 3
      DANGER = 4
      LINK = 5
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
    end
  end
end
