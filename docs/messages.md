# Messages and Components V2

[Documentation home](../README.md)

## Send and edit messages

`DiscordRuby::Bot` inherits the REST methods from `DiscordRuby::APIClient`. An API client can send a message without opening a Gateway connection:

```ruby
require 'discord_ruby'

client = DiscordRuby::APIClient.new(token: ENV.fetch('TOKEN'))
channel_id = ENV.fetch('CHANNEL_ID')
message = client.send_message(channel_id, 'Build complete.', allowed_mentions: {parse: []})
client.edit_message(channel_id, message.id, content: 'Build verified.')
```

`send_message` returns a `DiscordRuby::Message`; `edit_message` returns Discord's decoded response. You can also call `message.reply(content: '...')`, `message.edit(content: '...')`, `message.add_reaction('✅')`, `message.pin`, or `message.delete`. Omit fields on edit to leave them alone. Pass an empty `components: []` to clear controls from a legacy message.

The send helper accepts `content` as a positional argument or a keyword, plus `tts:`, `embeds:`, `components:`, `flags:`, `poll:`, `message_reference:`, `sticker_ids:`, `allowed_mentions:`, `attachments:`, and `files:`. The edit helper accepts `content:`, `embeds:`, `components:`, `flags:`, `allowed_mentions:`, and `attachments:`.

### Embeds and polls

Use embeds or polls with legacy message content:

```ruby
embed = DiscordRuby::Embed.build do |card|
  card.set_title('Build report')
  card.set_description('All checks passed.')
  card.set_color(0x2ECC71)
  card.add_field(name: 'Environment', value: 'Staging', inline: true)
end
client.send_message(channel_id, embeds: [embed])

poll = DiscordRuby::Builders::PollBuilder.new
  .question('What should we test next?')
  .add_answer('Commands')
  .add_answer('Components')
  .duration(24)

client.send_message(channel_id, poll: poll.to_h)
```

## Components V2

Use V2 components to lay out text, media, dividers, controls, and files. DiscordRuby adds `IS_COMPONENTS_V2` when it sees a V2 type in a message, including in raw component hashes. Action rows containing only legacy controls do not activate V2 by themselves. V2 messages use `TextDisplay` in place of `content` and cannot mix in embeds, polls, or stickers. Once a message switches to V2, it stays in V2.

```ruby
components = DiscordRuby::Component

section = components::Section.new
  .add_text('The build finished successfully.')
  .set_accessory(components::Button.new(
    style: DiscordRuby::Interaction::ButtonStyle::PRIMARY,
    label: 'Acknowledge',
    custom_id: 'build:ack'
  ))

card = components::Container.build(accent_color: 0xCC342D) do |container|
  container.add_text('## Build report')
  container.add_component(section)
  container.add_component(components::Separator.new(divider: false, spacing: 2))
  container.add_text('Environment: staging')
end

message = client.send_message(channel_id, components: [card])
puts message.components_v2?
```

To handle `build:ack`, register a component handler on a running bot. See [button updates](interactions.md#buttons-and-selects).

| Builder in `DiscordRuby::Component` | Placement and use |
| --- | --- |
| `TextDisplay.new(content)` | Markdown text at the root, inside a Container or Section, or as modal display text. |
| `Container.new(components:, accent_color:, spoiler:)` | Root-level card. Child components can include sections, rows, text, galleries, files, and separators. Use `Container.build` for a block, `add_text` for text, and `add_row` for controls. |
| `Section.new(components:, accessory:)` | Root-level or inside a Container. Use one to three text displays and a Button or Thumbnail accessory. |
| `Thumbnail.new(url:)` | Image in a Section accessory. Use `media_item:` with a `MediaItem` to set a description or spoiler. |
| `MediaGallery.new(items = [])` | Root-level or inside a Container. Add up to ten items via `add_item(url:, description: nil, spoiler: false)`. |
| `Separator.new(divider: true, spacing: 1)` | Root-level or inside a Container. Spacing `1` is small and `2` is large. |
| `File.new(url:, spoiler: false)` | Root-level or inside a Container. Use an `attachment://filename` reference. |
| `ActionRow.new(*components)` or `ActionRow.build` | Root-level or inside a Container. A message row holds up to five buttons or a single select. |
| `Button.new(style:, label:, custom_id:, url:, disabled:, emoji:)` | In a row or as a Section accessory. Give interactive buttons a unique `custom_id`. Link buttons use `url:` and do not dispatch an interaction. |
| `StringSelectMenu`, `UserSelectMenu`, `RoleSelectMenu`, `MentionableSelectMenu`, `ChannelSelectMenu` | In an action row, or under a Label in a modal. Message selects use `custom_id:`; string selects take `options:` with `SelectOption` objects or hashes. |

The library checks common V2 layout mistakes before the request, including duplicate custom IDs and the 40-component total. Discord still validates individual fields and permissions. [Discord component reference](https://docs.discord.com/developers/components/reference)

### Edit a message into V2

Pass V2 components to `edit_message` to replace a legacy layout. The library adds the V2 flag and clears the incompatible legacy fields when preparing the request:

```ruby
client.edit_message(channel_id, message.id, components: [
  DiscordRuby::Component::TextDisplay.new('## Updated build report')
])
```

### Attach a file

For a new channel message, map upload filenames to bytes or readable streams using `files:`. The component's URL must match the filename:

```ruby
client.send_message(
  channel_id,
  components: [DiscordRuby::Component::File.new(url: 'attachment://report.txt')],
  files: {'report.txt' => "Build passed.\n"}
)
```

Replace the example text with `File.binread(path)` to upload an existing file. The convenience upload option is on `send_message`. The edit and interaction helpers do not expose the same `files:` interface.

### Webhooks

Pass a payload hash as the third positional argument to `execute_webhook`. Use `wait: true` to get the created message. Treat webhook tokens like passwords.

```ruby
webhook_id = ENV.fetch('WEBHOOK_ID')
webhook_token = ENV.fetch('WEBHOOK_TOKEN')
text = DiscordRuby::Component::TextDisplay.new('Deployment complete.')
result = client.execute_webhook(webhook_id, webhook_token, {components: [text]}, wait: true)

replacement = DiscordRuby::Component::TextDisplay.new('Deployment verified.')
client.edit_webhook_message(webhook_id, webhook_token, result.fetch('id'), {
  components: [replacement]
})
```

The helper adds the `with_components` query parameter when it sends components. Discord limits interactive components on webhooks owned outside an application. The example uses display text only. [Discord webhook reference](https://docs.discord.com/developers/resources/webhook)
