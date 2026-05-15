module DiscordRuby
  module Utils
    class Colors
      DEFAULT = 0x000000
      WHITE = 0xffffff
      AQUA = 0x1abc9c
      GREEN = 0x57f287
      BLUE = 0x3498db
      YELLOW = 0xfee75c
      PURPLE = 0x9b59b6
      LUMINOUS_VIVID_PINK = 0xe91e63
      FUCHSIA = 0xeb459e
      GOLD = 0xf1c40f
      ORANGE = 0xe67e22
      RED = 0xed4245
      GREY = 0x95a5a6
      NAVY = 0x34495e
      DARK_AQUA = 0x11806a
      DARK_GREEN = 0x1f8b4c
      DARK_BLUE = 0x20669b
      DARK_PURPLE = 0x71368a
      DARK_VIVID_PINK = 0xad1457
      DARK_GOLD = 0xc27c0e
      DARK_ORANGE = 0xa84300
      DARK_RED = 0x992d22
      DARK_GREY = 0x979c9f
      DARKER_GREY = 0x7f8c8d
      LIGHT_GREY = 0xbcc0c0
      DARK_NAVY = 0x2c3e50
      BLURPLE = 0x5865f2
      GREYPLE = 0x99aab5
      DARK_BUT_NOT_BLACK = 0x2c2f33
      NOT_QUITE_BLACK = 0x23272a

      def self.random
        rand(0..0xffffff)
      end

    end

    class Snowflake
      DISCORD_EPOCH = 1420070400000

      def self.timestamp(id)

        ((id.to_i >> 22) + DISCORD_EPOCH) / 1000.0
      end

      def self.worker_id(id)
        (id.to_i & 0x3E0000) >> 17
      end

      def self.process_id(id)
        (id.to_i & 0x1F000) >> 12
      end

      def self.increment(id)
        id.to_i & 0xFFF
      end
    end
  end

end
