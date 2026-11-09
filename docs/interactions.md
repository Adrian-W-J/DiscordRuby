# Interactions and events

[Documentation home](../README.md)

## Register slash commands

A command needs a Discord registration and a local handler. Use `bot.register_guild_command(guild_id, payload)` for a test server or `bot.register_global_command(payload)` for the app's global command list. Call these after the application ID is available. See the [complete quickstart](getting-started.md#run-a-slash-command).

Use the builder for named options. The following assumes you already created `bot` and set `guild_id`, and goes before `bot.run!`:

```ruby
echo = DiscordRuby::Builders::SlashCommandBuilder.new
  .name('dr-echo')
  .description('Repeat a short message')
  .string_option(name: 'text', description: 'Text to repeat', required: true, max_length: 1000)

bot.on_command('dr-echo') do |interaction|
  interaction.reply(
    content: interaction.get_option('text'),
    ephemeral: true,
    allowed_mentions: {parse: []}
  )
end

bot.on_ready { bot.register_guild_command(guild_id, echo.to_h) }
```

Other option methods include `integer_option`, `number_option`, `boolean_option`, `user_option`, `role_option`, `channel_option`, `mentionable_option`, and `attachment_option`. Each takes `name:` and `description:`. `add_option` takes an explicit `type:`. Use `sub_command` and `sub_command_group` to define nested options. `get_option(name)` reads only the top level of the submitted option array; for subcommands, inspect the nested hashes in `interaction.options`.

`bulk_overwrite_guild_commands` and `bulk_overwrite_global_commands` replace the entire command list in their scope. Use the single-command methods to add or update one command.

## Reply, defer, and edit

| Method | When to use it |
| --- | --- |
| `reply(content:, components:, ephemeral:, **data)` | Send the initial response, using either legacy content or V2 components. |
| `defer_reply(ephemeral: false)` | Acknowledge first when work takes time. Finish the response with `edit_reply`. Set visibility on the defer call. |
| `edit_reply(**data)` | Change the original response. V2 components activate V2 on the edited message. |
| `follow_up(ephemeral: false, **data)` | Send another response after the original has been acknowledged and completed. |
| `fetch_reply` / `delete_reply` | Retrieve the original response as a decoded hash, or delete it. |
| `replied?` / `deferred?` | Check the acknowledgement state tracked by the interaction instance. |

Use one initial acknowledgement per interaction. Reply, defer, update, and opening a modal are different ways to acknowledge. Call the methods on the interaction object so the request uses that specific interaction's token.

```ruby
bot.on_command('dr-report') do |interaction|
  interaction.defer_reply(ephemeral: true)
  summary = DiscordRuby::Component::TextDisplay.new('## Report ready')
  interaction.edit_reply(components: [summary])
end
```

## Buttons and selects

Give interactive controls a custom ID and use that same ID in `on_component`. This button matches the [V2 message example](messages.md#components-v2):

```ruby
bot.on_component('build:ack') do |interaction|
  text = DiscordRuby::Component::TextDisplay.new('Build acknowledged.')
  interaction.update(components: [text])
end
```

`update(**data)` edits the source message as the initial response. Use `defer_update` to acknowledge first and `edit_reply` to complete the update later. Component interactions expose `custom_id`, `component_type`, `message`, and `values`. If only a particular user should be able to act, check `interaction.user.id` in the handler.

Here is a select menu and its matching handler. Add the row to a message's `components:` array:

```ruby
components = DiscordRuby::Component
select_row = components::ActionRow.build do |row|
  row.add_string_select(custom_id: 'build:environment', options: [
    components::SelectOption.new(label: 'Staging', value: 'staging'),
    components::SelectOption.new(label: 'Production', value: 'production')
  ])
end

bot.on_component('build:environment') do |interaction|
  interaction.reply(content: "Selected: #{interaction.values.join(', ')}", ephemeral: true)
end
```

## Modals

Open a modal as the initial response to a command or a button. Wrap inputs in `Component::Label` so the label and the input have separate fields. The modal's custom ID routes the submission. The input's custom ID is the key in `fields`.

```ruby
bot.on_command('dr-feedback') do |interaction|
  components = DiscordRuby::Component
  input = components::TextInput.new(
    custom_id: 'feedback',
    style: DiscordRuby::Interaction::TextInputStyle::PARAGRAPH,
    max_length: 500
  )
  modal = components::Modal.new(title: 'Feedback', custom_id: 'dr:feedback')
  modal.add_component(components::Label.new(label: 'Your feedback', component: input))
  interaction.show_modal(modal)
end

bot.on_modal_submit('dr:feedback') do |interaction|
  feedback = interaction.fields.fetch('feedback')
  interaction.reply(content: "Received #{feedback.length} characters.", ephemeral: true)
end
```

The parser accepts both labeled inputs and legacy action-row inputs. A select submission yields an array of selected values in `fields`. A text input yields a string.

## Gateway events and collectors

`on('EVENT_NAME')` receives the raw payload. Use the Gateway event name in uppercase, for example `MESSAGE_CREATE`. `on_message` wraps the same payload in a `DiscordRuby::Message`. Update events can contain only the changed fields. A bot reading message text needs the corresponding message intents:

```ruby
intents = DiscordRuby::Constants::Intents
bot = DiscordRuby::Bot.new(
  token: ENV.fetch('TOKEN'),
  intents: intents::GUILDS | intents::GUILD_MESSAGES | intents::MESSAGE_CONTENT
)

bot.on_message do |message|
  next if message.author&.bot_user
  next unless message.content == '!ping'

  message.reply(content: 'Pong!')
end

bot.run!
```

For a temporary listener, create an `InteractionCollector.new(bot, filter: ..., timeout: ..., max: ...)` or `MessageCollector.new(bot, channel_id, ...)`. Both begin listening on construction. Use `on_collect` to handle matches, `on_end` to receive the collected items and reason, and `end_collector` for manual cleanup. Message collectors pass raw hashes; interaction collectors pass interaction objects. Gateway listeners can run concurrently, so protect shared mutable state.

See the [event inventory and limitations](api-reference.md#gateway-and-bot) for method names and payload types.
