module DiscordRuby
  class Paginator
    def initialize(bot, interaction, pages, timeout: 60)
      @bot = bot
      @interaction = interaction
      @pages = pages
      @current_page = 0
      @timeout = timeout
      @message = nil
    end

    def start
      @message = render_current_page

      collector = InteractionCollector.new(@bot, timeout: @timeout, filter: ->(i) {
        i.user.id == @interaction.user.id && i.message.id == @message.id
      })

      collector.on_collect do |i|
        handle_interaction(i)
      end

      collector.on_end do
        disable_buttons
      end
    end

    private

    def render_current_page
      page = @pages[@current_page]
      data = page.is_a?(Hash) ? page : { content: page.to_s }
      data[:components] = [action_row]

      if @message.nil?
        if @interaction.replied? || @interaction.deferred?
          @interaction.edit_reply(**data)
          @interaction.fetch_reply
        else
          @interaction.reply(**data)
          @interaction.fetch_reply
        end
      else
        @interaction.edit_reply(**data)
        @message
      end
    end

    def action_row
      DiscordRuby::Component::ActionRow.new(
        DiscordRuby::Component::Button.new(style: DiscordRuby::Interaction::ButtonStyle::PRIMARY, label: '◀', custom_id: 'prev', disabled: @current_page == 0),
        DiscordRuby::Component::Button.new(style: DiscordRuby::Interaction::ButtonStyle::SECONDARY, label: "#{@current_page + 1}/#{@pages.size}", custom_id: 'page_info', disabled: true),
        DiscordRuby::Component::Button.new(style: DiscordRuby::Interaction::ButtonStyle::PRIMARY, label: '▶', custom_id: 'next', disabled: @current_page == @pages.size - 1)
      )
    end

    def handle_interaction(i)
      case i.custom_id
      when 'prev'
        @current_page -= 1 if @current_page > 0
      when 'next'
        @current_page += 1 if @current_page < @pages.size - 1
      end

      i.defer_update
      render_current_page
    end

    def disable_buttons
      page = @pages[@current_page]
      data = page.is_a?(Hash) ? page : { content: page.to_s }

      row = action_row
      row.components.each { |c| c.instance_variable_set(:@disabled, true) if c.respond_to?(:custom_id) }
      data[:components] = [row]

      @interaction.edit_reply(**data) rescue nil
    end
  end
end
