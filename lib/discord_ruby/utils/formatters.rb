module DiscordRuby
  module Utils
    module Formatters
      def self.bold(text)
        "**#{text}**"
      end

      def self.italic(text)
        "*#{text}*"
      end

      def self.underline(text)
        "__#{text}__"
      end

      def self.strikethrough(text)
        "~~#{text}~~"
      end

      def self.spoiler(text)
        "||#{text}||"
      end

      def self.inline_code(text)
        "`#{text}`"
      end

      def self.code_block(text, language = nil)
        "```#{language}\n#{text}\n```"
      end

      def self.quote(text)
        "> #{text}"
      end

      def self.block_quote(text)
        ">>> #{text}"
      end

      def self.user_mention(user_id)
        "<@#{user_id}>"
      end

      def self.nickname_mention(user_id)
        "<@!#{user_id}>"
      end

      def self.channel_mention(channel_id)
        "<##{channel_id}>"
      end

      def self.role_mention(role_id)
        "<@&#{role_id}>"
      end

      def self.emoji_mention(name, id, animated: false)
        "<#{animated ? 'a' : ''}:#{name}:#{id}>"
      end

      def self.timestamp(time, style = nil)
        t = time.to_i
        style ? "<t:#{t}:#{style}>" : "<t:#{t}>"
      end

      def self.hyperlink(text, url)
        "[#{text}](#{url})"
      end

      def self.hide_link_embed(url)
        "<#{url}>"
      end

      def self.subtext(text)
        "-# #{text}"
      end

      def self.heading1(text)
        "# #{text}"
      end

      def self.heading2(text)
        "## #{text}"
      end

      def self.heading3(text)
        "### #{text}"
      end

      def self.list_item(text, bullet: '-')
        "#{bullet} #{text}"
      end

      def self.ordered_list_item(text, index: 1)
        "#{index}. #{text}"
      end

      def self.clean_content(content)
        content.gsub('@everyone', '@​everyone').gsub('@here', '@​here')
      end

      def self.escape_markdown(text)
        text.gsub(/([*_~`|>\\#\-\[\]])/, '\\\\\1')
      end

      def self.escape_bold(text)
        text.gsub('**', '\\*\\*')
      end

      def self.escape_italic(text)
        text.gsub('*', '\\*').gsub('_', '\\_')
      end

      def self.escape_underline(text)
        text.gsub('__', '\\_\\_')
      end

      def self.escape_strikethrough(text)
        text.gsub('~~', '\\~\\~')
      end

      def self.escape_spoiler(text)
        text.gsub('||', '\\|\\|')
      end

      def self.escape_inline_code(text)
        text.gsub('`', '\\`')
      end

      def self.escape_code_block(text)
        text.gsub('```', '\\`\\`\\`')
      end

      def self.parse_snowflake(id)
        snowflake = id.to_i
        {
          timestamp: (snowflake >> 22) + 1420070400000,
          worker_id: (snowflake & 0x3E0000) >> 17,
          process_id: (snowflake & 0x1F000) >> 12,
          increment: snowflake & 0xFFF
        }
      end

      module Styles
        SHORT_TIME = 't'
        LONG_TIME = 'T'
        SHORT_DATE = 'd'
        LONG_DATE = 'D'
        SHORT_DATETIME = 'f'
        LONG_DATETIME = 'F'
        RELATIVE = 'R'
      end
    end
  end
end
