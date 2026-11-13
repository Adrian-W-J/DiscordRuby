# Additional Discord features

[Documentation home](../README.md)

## Autocomplete, context menus, and user-installed apps

Set `autocomplete: true` on a string, integer, or number option. Register the matching handler before starting the bot.

```ruby
bot.on_autocomplete('search') do |interaction|
  query = interaction.focused_option&.fetch('value', '').to_s.downcase
  choices = %w[Ruby Rails Bundler].select { |name| name.downcase.start_with?(query) }
  interaction.respond(choices.map { |name| {name: name, value: name.downcase} })
end
```

Use `SlashCommandBuilder#type(2)` for a user context menu and `type(3)` for a message context menu. In the command handler, `interaction.target` returns the selected User or Message. The raw resolved objects are available through `interaction.resolved`.

Global commands can declare `integration_types(0, 1)` for guild and user installs and `contexts(0, 1, 2)` for guild channels, the app's DM, and other private channels. Configure the corresponding installation types for the application in Discord. Interaction objects expose `context`, `authorizing_integration_owners`, `locale`, `guild_locale`, and `entitlements`. Options accept `name_localizations:` and `description_localizations:`. Localize choice names with `name_localizations` in each choice hash. [Discord application commands](https://docs.discord.com/developers/interactions/application-commands)

Use `fetch_application_commands(application_id, with_localizations: true)` to retrieve localization dictionaries.

## Command permissions

`fetch_command_permissions(application_id, guild_id, command_id: nil)` reads guild-level or command-specific permissions. `edit_command_permissions(application_id, guild_id, command_id, permissions:, bearer_token:)` replaces the command's permission overrides. Supply a user OAuth bearer token with the `applications.commands.permissions.update` scope and the guild permissions Discord requires. Keep that token in your environment or secret store. [Discord command permissions](https://docs.discord.com/developers/interactions/application-commands#permissions)

Listen for updates with `bot.on_application_command_permissions_update`.

## Forum posts, stickers, and forwarding

```ruby
client.create_forum_post(forum_channel_id, name: 'Release notes',
                        message: {content: 'The new release is ready.'},
                        applied_tags: [release_tag_id])

File.open('party.png', 'rb') do |file|
  client.create_guild_sticker(guild_id, name: 'Party', description: '', tags: 'party', file: file)
end

client.forward_message(destination_channel_id, source_channel_id: source_channel_id,
                       message_id: message_id, guild_id: guild_id)
```

`create_forum_post` also accepts an initial Components V2 message and a `files:` map. Its response includes the new thread and starter message. Use `Channel#create_forum_post` if you already have the forum channel model.

For sticker bytes without an open file, pass `filename:` with a supported extension. For forwarded messages received from Discord, use `message.message_snapshots` to read the captured content. A message already loaded as a model can be forwarded with `message.forward_to(destination_channel_id)`.

## Application emoji and monetization

Use `list_application_emojis`, `fetch_application_emoji`, `create_application_emoji`, `edit_application_emoji`, and `delete_application_emoji` with the application ID. Creating an emoji takes `name:` and a Discord image data URI in `image:`. [Discord emoji resource](https://docs.discord.com/developers/resources/emoji)

Use `list_skus`, `list_sku_subscriptions`, and `fetch_sku_subscription` to inspect offerings and subscriptions. Use `list_entitlements` or `fetch_entitlement` to check access, and `consume_entitlement` after delivering a consumable purchase. The bot exposes `on_subscription_create`, `on_subscription_update`, and `on_subscription_delete` alongside the existing entitlement events.

To display a purchase button for a configured SKU, add `row.add_button(style: DiscordRuby::Interaction::ButtonStyle::PREMIUM, sku_id: sku_id)` to an action row. Discord manages the purchase flow. [Discord entitlement resource](https://docs.discord.com/developers/resources/entitlement)

## Sharding, caches, and the command framework

Use `DiscordRuby::ShardGroup.new(token: ENV.fetch('TOKEN'))` to use Discord's recommended shard count, or pass `total_shards:` explicitly. Register handlers on each bot in `group.bots`, then call `group.run!`. Use `group.bot_for_guild(guild_id)` to select a shard and `group.stop!` to close its connections. For a manually managed shard, pass `shard: [id, count]` to `Bot.new`.

Bot caches accept a `cache_size:` limit and an optional `cache_ttl:` in seconds. A size of zero disables storage, and `nil` removes the size limit. Cached entries expire after their last write. Call `bot.sweep_caches` to remove expired entries across the bot and get the number removed. Cache methods synchronize access across Gateway handler threads.

Bots in the same shard group share REST rate-limit state. Set `open_timeout:` and `read_timeout:` on a bot to configure its HTTP timeouts. Failed HTTP responses raise `DiscordRuby::APIError` with `status` and `body`. If a rate limit persists after retries, the REST client raises `DiscordRuby::RateLimitError`.

`Commands::Framework.new(bot)` supports `slash_command` definitions with options, checks, and an `execute` block. It routes commands through the bot's regular handlers. Call `sync_commands(guild_id)` after READY to replace the test guild's registered command list.

## Additional modal inputs

Place `Component::FileUpload`, `RadioGroup`, `CheckboxGroup`, or `Checkbox` inside a `Component::Label`. Option groups accept hashes with `label` and `value`. Use `interaction.fields[custom_id]` for submitted values or `interaction.files(custom_id)` to resolve uploads to attachment models. [Discord component reference](https://docs.discord.com/developers/components/reference)

## Message managers, webhooks, and collectors

Use `channel.messages` to fetch, create, edit, and delete messages. `fetch(id)` uses the bot's cache when possible. Use `force: true` to make a REST request and `cache: false` to skip storing the result. `fetch_all` accepts `limit:`, `before:`, `after:`, and `around:`.

`channel.create_webhook(name)` and `channel.fetch_webhooks` return webhook models. A webhook with a token can send, fetch, edit, or delete messages in a thread by passing `thread_id:`. Sending and editing accept a `files:` map. `webhook.send` waits for a message by default. Set `wait: false` for an empty response.

```ruby
message = channel.messages.create('React to vote')
collector = message.create_reaction_collector(timeout: 30, max: 10)
collector.on_collect { |reaction| puts reaction['user_id'] }
collector.on_end { |reactions, reason| puts "#{reactions.size} votes, ended by #{reason}" }
```

Use `channel.create_message_collector` for messages or `message.create_component_collector` for component interactions. Collectors accept a `filter:` callable and optional `timeout:` and `idle:` durations in seconds. Call `end_collector` to stop manually.

## Voice state

`bot.update_voice_state(guild_id, channel_id, self_mute: false, self_deaf: false)` sends the Gateway voice-state request. Pass `nil` for the channel to request leaving. Audio streaming requires a separate DAVE-capable voice transport. [Discord voice connections](https://docs.discord.com/developers/topics/voice-connections)
