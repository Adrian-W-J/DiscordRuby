# DiscordRuby

DiscordRuby is a Ruby library for building Discord bots. It provides a Gateway client for events and interactions, REST helpers for Discord API v10, and builders for commands, messages, Components V2, and modals.

These docs cover the local **0.3.0** source. Start with the checkout and Bundler.

| Guide | What it covers |
| --- | --- |
| [Getting started](docs/getting-started.md) | Create a test bot, configure its token and permissions, and run a guild-only slash command |
| [Messages and Components V2](docs/messages.md) | Plain messages, embeds, polls, V2 cards, buttons, select menus, attachments, and webhooks |
| [Interactions and events](docs/interactions.md) | Register commands, reply or defer, update messages, open modals, and listen for events |
| [API reference](docs/api-reference.md) | Public REST and Gateway methods, return types, builders, models, and implementation gaps |
| [Additional Discord features](docs/feature-coverage.md) | Autocomplete, context menus, user installs, permissions, forums, stickers, forwarding, app emoji, and monetization |

From the repository root, install dependencies and check that the library loads:

```powershell
bundle install
bundle exec ruby -Ilib -rdiscord_ruby -e 'puts DiscordRuby::VERSION'
```

Run the offline regression suite with `ruby -Ilib test/components_v2_test.rb`. The test runner needs Minitest installed in your Ruby environment.

[MIT license](LICENSE)
