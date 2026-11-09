require_relative '../lib/discord_ruby'

bot = DiscordRuby::Bot.new(token: ENV.fetch('TOKEN'), intents: 0)
framework = DiscordRuby::Commands::Framework.new(bot)


puts DiscordRuby::Utils::Formatters.table(['Name', 'ID'], [['Bot', '123'], ['User', '456']])
puts DiscordRuby::Utils::Formatters.progress_bar(7, 10)


class MyWizard < DiscordRuby::Wizard
  def configure
    state :start do
      render do |w, data|
        { content: "Welcome! Click a button.", components: [
          DiscordRuby::Component::ActionRow.new(
            DiscordRuby::Component::Button.new(style: DiscordRuby::Interaction::ButtonStyle::PRIMARY, label: "Option A", custom_id: "a"),
            DiscordRuby::Component::Button.new(style: DiscordRuby::Interaction::ButtonStyle::SECONDARY, label: "Option B", custom_id: "b")
          )
        ]}
      end

      on_interaction do |w, i, data|
        w.set_data(:choice, i.custom_id)
        :next_step
      end
    end

    state :next_step do
      render do |w, data|
        { content: "You chose #{data[:choice]}! Are you sure?", components: [
          DiscordRuby::Component::ActionRow.new(
            DiscordRuby::Component::Button.new(style: DiscordRuby::Interaction::ButtonStyle::SUCCESS, label: "Yes", custom_id: "yes"),
            DiscordRuby::Component::Button.new(style: DiscordRuby::Interaction::ButtonStyle::DANGER, label: "No", custom_id: "no")
          )
        ]}
      end

      on_interaction do |w, i, data|
        i.custom_id == 'yes' ? :finish : :start
      end
    end
  end

  def finish
    interaction.edit_reply(content: "Wizard finished! Result: #{get_data(:choice)}", components: [])
  end
end


framework.slash_command('test', 'Test command') do |c|
  c.string_option('type', 'Type of test')

  c.check do |interaction|

    interaction.user.id == '123456789'
  end

  c.execute do |interaction|
    type = interaction.get_option('type')

    if type == 'wizard'
      MyWizard.new(bot, interaction).start(:start)
    elsif type == 'pages'
      pages = [
        "Page 1: Welcome",
        "Page 2: Middle",
        { content: "Page 3: End", embeds: [DiscordRuby::Embed.new(title: "Final Page")] }
      ]
      DiscordRuby::Paginator.new(bot, interaction, pages).start
    else
      interaction.reply(content: "Hello! Try `/test type:wizard` or `/test type:pages`")
    end
  end
end


