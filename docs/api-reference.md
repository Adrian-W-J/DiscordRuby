# API reference

[Documentation home](../README.md)

## Gateway and Bot

`DiscordRuby::Bot.new(token:, intents: 513, gateway_url: nil, cache_size: 1000)` combines the REST client and Gateway. The default intents are `GUILDS | GUILD_MESSAGES`. Pass an integer bitmask built from `DiscordRuby::Constants::Intents` to request other event categories. Request privileged intents only where the bot needs them.

- `run!` opens the Gateway and blocks. Register handlers before calling it. `stop!` delegates to the Gateway's disconnect method.
- `on(event, &block)` returns a listener ID; pass it to `off(event, handler_id)`. `on('error')` receives an exception. `on_ready` receives the READY hash and sets `application_id` before invoking your block.
- `on_interaction(&block)` receives a parsed interaction and returns an ID for `off_interaction(handler_id)`. Use `on_command`, `on_component`, and `on_modal_submit` to route by name or custom ID. Treat an interaction's `token` as a credential.
- `register_guild_command(guild_id, data)`, `register_global_command(data)`, `delete_command(command_id, guild_id: nil)`, and the bulk overwrite methods use `application_id`. For REST-only scripts, use the variants that take an application ID explicitly.
- `set_presence(status: 'online', activities: [], afk: false, since: nil)`, `set_status(status)`, and `set_activity(name, type: 0, url: nil)` send presence updates over the Gateway.
- `users`, `guilds`, `channels`, `members`, and `messages` expose `Cache` instances. The cache supports `get`, `set`, `delete`, `clear`, `keys`, and `values`. A cache can be incomplete. Fetch from REST when you need a current object.

### Event inventory

Each method below takes a block. Use the raw event string with `on` when you need the original payload.

| Bot method | Gateway event | Callback argument |
| --- | --- | --- |
| `on_ready` | `READY` | Raw hash |
| `on_message` | `MESSAGE_CREATE` | `Message` |
| `on_message_update` | `MESSAGE_UPDATE` | `Message` |
| `on_message_delete` | `MESSAGE_DELETE` | Raw hash |
| `on_guild_create` | `GUILD_CREATE` | `Guild` |
| `on_guild_update` | `GUILD_UPDATE` | `Guild` |
| `on_guild_delete` | `GUILD_DELETE` | Raw hash |
| `on_entitlement_create` | `ENTITLEMENT_CREATE` | Raw hash |
| `on_entitlement_update` | `ENTITLEMENT_UPDATE` | Raw hash |
| `on_entitlement_delete` | `ENTITLEMENT_DELETE` | Raw hash |
| `on_poll_vote_add` | `MESSAGE_POLL_VOTE_ADD` | Raw hash |
| `on_poll_vote_remove` | `MESSAGE_POLL_VOTE_REMOVE` | Raw hash |
| `on_member_add` | `GUILD_MEMBER_ADD` | `Member` |
| `on_member_update` | `GUILD_MEMBER_UPDATE` | `Member` |
| `on_member_remove` | `GUILD_MEMBER_REMOVE` | `Member` |
| `on_reaction_add` | `MESSAGE_REACTION_ADD` | Raw hash |
| `on_reaction_remove` | `MESSAGE_REACTION_REMOVE` | Raw hash |
| `on_reaction_remove_all` | `MESSAGE_REACTION_REMOVE_ALL` | Raw hash |
| `on_reaction_remove_emoji` | `MESSAGE_REACTION_REMOVE_EMOJI` | Raw hash |
| `on_typing_start` | `TYPING_START` | Raw hash |
| `on_voice_state_update` | `VOICE_STATE_UPDATE` | Raw hash |
| `on_voice_server_update` | `VOICE_SERVER_UPDATE` | Raw hash |
| `on_thread_create` | `THREAD_CREATE` | `Channel` |
| `on_thread_update` | `THREAD_UPDATE` | `Channel` |
| `on_thread_delete` | `THREAD_DELETE` | `Channel` |
| `on_thread_list_sync` | `THREAD_LIST_SYNC` | Raw hash |
| `on_thread_member_update` | `THREAD_MEMBER_UPDATE` | Raw hash |
| `on_thread_members_update` | `THREAD_MEMBERS_UPDATE` | Raw hash |
| `on_guild_ban_add` | `GUILD_BAN_ADD` | Raw hash |
| `on_guild_ban_remove` | `GUILD_BAN_REMOVE` | Raw hash |
| `on_guild_emojis_update` | `GUILD_EMOJIS_UPDATE` | Raw hash |
| `on_guild_stickers_update` | `GUILD_STICKERS_UPDATE` | Raw hash |
| `on_guild_integrations_update` | `GUILD_INTEGRATIONS_UPDATE` | Raw hash |
| `on_guild_role_create` | `GUILD_ROLE_CREATE` | `Role` |
| `on_guild_role_update` | `GUILD_ROLE_UPDATE` | `Role` |
| `on_guild_role_delete` | `GUILD_ROLE_DELETE` | Raw hash |
| `on_channel_create` | `CHANNEL_CREATE` | `Channel` |
| `on_channel_update` | `CHANNEL_UPDATE` | `Channel` |
| `on_channel_delete` | `CHANNEL_DELETE` | `Channel` |
| `on_guild_scheduled_event_create` | `GUILD_SCHEDULED_EVENT_CREATE` | `ScheduledEvent` |
| `on_guild_scheduled_event_update` | `GUILD_SCHEDULED_EVENT_UPDATE` | `ScheduledEvent` |
| `on_guild_scheduled_event_delete` | `GUILD_SCHEDULED_EVENT_DELETE` | `ScheduledEvent` |
| `on_guild_scheduled_event_user_add` | `GUILD_SCHEDULED_EVENT_USER_ADD` | Raw hash |
| `on_guild_scheduled_event_user_remove` | `GUILD_SCHEDULED_EVENT_USER_REMOVE` | Raw hash |
| `on_integration_create` | `INTEGRATION_CREATE` | Raw hash |
| `on_integration_update` | `INTEGRATION_UPDATE` | Raw hash |
| `on_integration_delete` | `INTEGRATION_DELETE` | Raw hash |
| `on_invite_create` | `INVITE_CREATE` | Raw hash |
| `on_invite_delete` | `INVITE_DELETE` | Raw hash |
| `on_presence_update` | `PRESENCE_UPDATE` | `Presence` |
| `on_stage_instance_create` | `STAGE_INSTANCE_CREATE` | `StageInstance` |
| `on_stage_instance_update` | `STAGE_INSTANCE_UPDATE` | `StageInstance` |
| `on_stage_instance_delete` | `STAGE_INSTANCE_DELETE` | `StageInstance` |
| `on_webhooks_update` | `WEBHOOKS_UPDATE` | Raw hash |
| `on_auto_moderation_rule_create` | `AUTO_MODERATION_RULE_CREATE` | Raw hash |
| `on_auto_moderation_rule_update` | `AUTO_MODERATION_RULE_UPDATE` | Raw hash |
| `on_auto_moderation_rule_delete` | `AUTO_MODERATION_RULE_DELETE` | Raw hash |
| `on_auto_moderation_action_execution` | `AUTO_MODERATION_ACTION_EXECUTION` | Raw hash |

## REST client

`DiscordRuby::APIClient.new(token:, default_headers: {})` works without a Gateway connection. The methods below are also available on `Bot`. Use string IDs for Discord objects. Unless a helper wraps the result in a model, methods return the decoded JSON response with string keys. An empty response becomes `{}`. For a JSON error response, the client raises with Discord's status and error payload.

`request(method, path, params: nil, body: nil, headers: {}, files: {})` accepts an API-relative path such as `'/users/@me'`. Use `params` for query parameters and `body` for JSON. `files` selects multipart encoding and takes a filename-to-bytes-or-IO hash. The API response determines which fields and permissions are required. The client does not currently retry a rate-limited REST request for you.

### Common return types

| Methods | Result |
| --- | --- |
| `send_message`, `send_dm` | `Message` |
| `edit_message`, `fetch_channel_messages` | Decoded message hash or array of message hashes |
| `fetch_user`, `fetch_channel`, `fetch_guild`, `fetch_guild_member` | `User`, `Channel`, `Guild`, or `Member` |
| `fetch_guild_channels`, `list_guild_members`, `fetch_guild_roles`, `fetch_guild_emojis`, `fetch_guild_stickers` | Arrays of the corresponding models |
| `execute_webhook` with `wait: true`, `get_original_interaction_response` | Decoded message hash |

### REST method signatures

The signatures show Ruby arguments and defaults. Methods that take `**options` generally forward the supplied fields to Discord. For send and edit options and V2 validation, see the [message guide](messages.md).

#### Transport, users, and channels

```text
initialize(token:, default_headers: {})
request(method, path, params: nil, body: nil, headers: {}, files: {})
fetch_my_user
fetch_user(user_id)
modify_current_user(username: nil, avatar: nil)
fetch_channel(channel_id)
fetch_channel_messages(channel_id, limit: 50, before: nil, after: nil, around: nil)
```

#### Messages, reactions, and pins

```text
send_message(channel_id, content = nil, files: {}, **options)
edit_message(channel_id, message_id, **options)
pin_message(channel_id, message_id)
unpin_message(channel_id, message_id)
fetch_pinned_messages(channel_id)
delete_message(channel_id, message_id)
bulk_delete_messages(channel_id, message_ids)
crosspost_message(channel_id, message_id)
add_reaction(channel_id, message_id, emoji)
remove_reaction(channel_id, message_id, emoji, user_id = '@me')
clear_reactions(channel_id, message_id)
fetch_reactions(channel_id, message_id, emoji, limit: 25, after: nil)
```

#### Invites, guilds, and channels

```text
create_channel_invite(channel_id, **options)
fetch_channel_invites(channel_id)
delete_channel_invite(invite_code)
fetch_guild(guild_id)
edit_guild(guild_id, **options)
delete_guild(guild_id)
fetch_guild_channels(guild_id)
create_guild_channel(guild_id, name, type, **options)
```

#### Members, bans, pruning, and roles

```text
fetch_guild_member(guild_id, user_id)
list_guild_members(guild_id, limit: 1000, after: nil)
add_guild_member(guild_id, user_id, access_token:, **options)
modify_guild_member(guild_id, user_id, **options)
remove_guild_member(guild_id, user_id, reason: nil)
create_guild_ban(guild_id, user_id, delete_message_days: 0, reason: nil)
remove_guild_ban(guild_id, user_id, reason: nil)
leave_guild(guild_id)
get_guild_prune_count(guild_id, days: 7, include_roles: nil)
begin_guild_prune(guild_id, days: 7, compute_prune_count: true, include_roles: nil, reason: nil)
add_guild_member_role(guild_id, user_id, role_id, reason: nil)
remove_guild_member_role(guild_id, user_id, role_id, reason: nil)
fetch_guild_roles(guild_id)
create_guild_role(guild_id, **options)
edit_guild_role(guild_id, role_id, **options)
delete_guild_role(guild_id, role_id)
```

#### Emojis, stickers, voice regions, and audit logs

```text
fetch_guild_emojis(guild_id)
create_guild_emoji(guild_id, name:, image:, **options)
edit_guild_emoji(guild_id, emoji_id, **options)
delete_guild_emoji(guild_id, emoji_id)
fetch_guild_stickers(guild_id)
fetch_guild_sticker(guild_id, sticker_id)
create_guild_sticker(guild_id, name:, description:, tags:, file:, **options)
edit_guild_sticker(guild_id, sticker_id, **options)
delete_guild_sticker(guild_id, sticker_id)
list_voice_regions
fetch_guild_voice_regions(guild_id)
fetch_guild_audit_log(guild_id, **params)
```

#### Scheduled events

```text
list_guild_scheduled_events(guild_id, with_user_count: false)
create_guild_scheduled_event(guild_id, **options)
fetch_guild_scheduled_event(guild_id, event_id, with_user_count: false)
edit_guild_scheduled_event(guild_id, event_id, **options)
delete_guild_scheduled_event(guild_id, event_id)
fetch_guild_scheduled_event_users(guild_id, event_id, limit: 100, with_member: false, before: nil, after: nil)
```

#### Templates, welcome screens, and onboarding

```text
fetch_guild_template(template_code)
create_guild_from_template(template_code, name, icon: nil)
fetch_guild_templates(guild_id)
create_guild_template(guild_id, name:, description: nil)
sync_guild_template(guild_id, template_code)
edit_guild_template(guild_id, template_code, **options)
delete_guild_template(guild_id, template_code)
fetch_guild_welcome_screen(guild_id)
edit_guild_welcome_screen(guild_id, **options)
fetch_guild_onboarding(guild_id)
edit_guild_onboarding(guild_id, **options)
```

#### Entitlements and polls

```text
list_entitlements(application_id, **params)
create_test_entitlement(application_id, sku_id, owner_id, owner_type)
delete_test_entitlement(application_id, entitlement_id)
expire_poll(channel_id, message_id)
fetch_poll_answer_voters(channel_id, message_id, answer_id, after: nil, limit: 100)
```

#### Threads

```text
start_thread_from_message(channel_id, message_id, name:, auto_archive_duration: nil, rate_limit_per_user: nil)
start_thread_without_message(channel_id, name:, auto_archive_duration: nil, type: nil, invitable: nil, rate_limit_per_user: nil)
join_thread(channel_id)
add_thread_member(channel_id, user_id)
leave_thread(channel_id)
remove_thread_member(channel_id, user_id)
fetch_thread_member(channel_id, user_id)
list_thread_members(channel_id)
list_active_threads(guild_id)
list_public_archived_threads(channel_id, before: nil, limit: nil)
list_private_archived_threads(channel_id, before: nil, limit: nil)
list_joined_private_archived_threads(channel_id, before: nil, limit: nil)
```

#### Webhooks

```text
create_webhook(channel_id, name:, avatar: nil)
fetch_channel_webhooks(channel_id)
fetch_guild_webhooks(guild_id)
fetch_webhook(webhook_id)
fetch_webhook_with_token(webhook_id, token)
edit_webhook(webhook_id, name: nil, avatar: nil, channel_id: nil)
delete_webhook(webhook_id)
```

#### Auto moderation and stages

```text
list_auto_moderation_rules(guild_id)
fetch_auto_moderation_rule(guild_id, rule_id)
create_auto_moderation_rule(guild_id, **options)
edit_auto_moderation_rule(guild_id, rule_id, **options)
delete_auto_moderation_rule(guild_id, rule_id)
create_stage_instance(channel_id, topic:, privacy_level: nil, send_start_notification: nil)
fetch_stage_instance(channel_id)
edit_stage_instance(channel_id, topic: nil, privacy_level: nil)
delete_stage_instance(channel_id)
```

#### Direct messages and application commands

```text
create_dm_channel(user_id)
send_dm(user_id, content, **options)
fetch_application_commands(application_id, guild_id: nil)
create_global_application_command(application_id, data)
create_guild_application_command(application_id, guild_id, data)
delete_application_command(application_id, command_id, guild_id: nil)
edit_application_command(application_id, command_id, data, guild_id: nil)
bulk_overwrite_global_application_commands(application_id, commands)
bulk_overwrite_guild_application_commands(application_id, guild_id, commands)
```

#### Interaction callbacks and webhook messages

```text
create_interaction_response(interaction_id, token, type, data = {})
create_autocomplete_response(interaction_id, token, choices)
create_modal_response(interaction_id, token, modal)
edit_original_interaction_response(application_id, token, data = {})
get_original_interaction_response(application_id, token)
delete_original_interaction_response(application_id, token)
create_followup_message(application_id, token, data = {})
execute_webhook(webhook_id, webhook_token, data = {}, wait: false, thread_id: nil)
edit_webhook_message(webhook_id, webhook_token, message_id, data = {}, thread_id: nil)
delete_webhook_message(webhook_id, webhook_token, message_id)
```

## Models and builders

Models expose `id` as a string and `to_h` for their raw data. Read model attributes directly when available. For example, use `message.channel_id`, `user.username`, or `member.nick`. `Permissions.new(bitfield).has?(:send_messages)` checks a named permission, and `to_a` lists permissions recognised by the library. Discord still makes the final decision on API requests.

| Model | Common operations |
| --- | --- |
| `Message` | `reply(content:, **options)`, `edit(**options)`, `components_v2?`, `add_reaction(emoji)`, `pin`, `unpin`, `delete`, `start_thread(name:, auto_archive_duration: nil)` |
| `Channel` | `send_message(content, **options)`, `fetch_messages(limit: 50)`, `create_thread(name:, type: nil, auto_archive_duration: nil)`, `thread?` |
| `Guild` | `fetch_channels`, `fetch_members(limit: 1000, after: nil)`, `fetch_audit_logs(**params)`, `fetch_active_threads` |
| `Member` | `timeout(until_time, reason: nil)`, `set_nickname(nick, reason: nil)`, `add_role(role_id, reason: nil)`, `remove_role(role_id, reason: nil)`, `kick(reason: nil)`, `ban(delete_message_days: 0, reason: nil)` |
| `User`, `Role`, `Emoji` | `mention`; users also expose `tag`, `bot_user`, `avatar_url`, and `send_dm(content, **options)` |

Builders assemble payloads locally. They perform no REST calls on their own.

- `Builders::MessageBuilder.build { |b| ... }` returns keyword arguments for `send_message` or an interaction reply. Use `content` and `add_embed` for legacy messages, or `text_display`, `container`, and `add_component` for V2. The builder's `ephemeral` option is for interaction responses.
- `DiscordRuby::Embed.build { |e| ... }` returns an embed object. Use its `set_*` methods and `add_field`. `Builders::EmbedBuilder.build` returns a hash containing an array of embeds.
- `Builders::SlashCommandBuilder.new` and `Builders::PollBuilder.new` return builder objects. Call `to_h` before passing their payloads to the corresponding REST methods.
- `Component::Modal` with `Component::Label` is the primary modal path in this guide. `Builders::ModalBuilder` produces the older action-row layout.
- Additional payload builders return hashes through `build`: `GuildBuilder`, `ChannelBuilder`, `RoleBuilder`, `InviteBuilder`, `WebhookBuilder`, `ScheduledEventBuilder`, `AutoModerationRuleBuilder`, `StickerBuilder`, `StageInstanceBuilder`, `AllowedMentionsBuilder`, `ThreadBuilder`, `ForumPostBuilder`, `EmojiBuilder`, `SoundboardSoundBuilder`, `ApplicationRoleConnectionMetadataBuilder`. A builder's presence does not imply a matching dedicated endpoint.

## Utilities

`DiscordRuby::Utils::Formatters` provides Markdown helpers such as `bold`, `code_block`, `escape_markdown`, and `hyperlink`, plus `user_mention`, `channel_mention`, `role_mention`, `timestamp`, `table`, `progress_bar`, and `parse_snowflake`. These return formatted data locally. Use `allowed_mentions: {parse: []}` when relaying untrusted text and you do not want it to ping anyone.

## Current limitations

- The normal `require 'discord_ruby'` entry point loads `Bot` and the models listed above. Some similarly named classes and utilities in the repository are outside that entry point. Use the methods described here when starting a bot.
- The checkout exposes `Commands::Framework`, but its builder and event hookup do not match the default load path. Use `on_command` with `register_guild_command` or `register_global_command`. Autocomplete has a low-level response method, but `on_autocomplete` is not dispatched by the current Bot implementation.
- `Paginator` and `Wizard` are experimental. Their collector logic expects message objects from `fetch_reply`, which currently returns a hash. Use explicit component handlers for multi-step flows.
- The sticker creation helper has no multipart upload implementation. The message file upload example is supported through the separate `send_message(files: ...)` path.
- Offline checks cover the V2 request payloads and modal parsing. They do not verify Discord-side permissions or rendering in your server.
