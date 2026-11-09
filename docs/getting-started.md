# Getting started

[Documentation home](../README.md)

## Install from the checkout

Install Ruby and Bundler, then open a shell in the DiscordRuby repository and run `bundle install`. The local 0.3.0 checks were run on Ruby 4.0.3. This checkout does not declare a minimum Ruby version.

Use `bundle exec ruby -Ilib your_bot.rb` for scripts in the repository. The `-Ilib` switch makes `require 'discord_ruby'` resolve to this checkout.

## Create a test bot

1. Create an application in the [Discord Developer Portal](https://discord.com/developers/applications) and open its **Bot** page to configure the bot user.
2. Configure a server installation with the `bot` and `applications.commands` scopes, then install the application in a server you control. For the channel message examples, give the bot **View Channel** and **Send Messages** in your test channel. Attachment and embed examples also require the corresponding channel permissions.
3. Enable Discord Developer Mode and copy your test server's ID. In the examples, `GUILD_ID` is the server ID and `CHANNEL_ID` is the ID of a text channel inside it.
4. Set `TOKEN` in the environment of the shell that will run the bot. The library reads the value you pass to `Bot.new`. It does not load dotenv files automatically. Keep tokens out of source files and screenshots. If a token was exposed, reset it in the Developer Portal.

PowerShell setup with a masked prompt:

```powershell
$tokenInput = Read-Host 'Discord bot token' -AsSecureString
$env:TOKEN = [System.Net.NetworkCredential]::new('', $tokenInput).Password
$env:GUILD_ID = 'YOUR_TEST_SERVER_ID'
```

## Run a slash command

Save this as `quickstart.rb` in the repository root:

```ruby
require 'discord_ruby'

bot = DiscordRuby::Bot.new(
  token: ENV.fetch('TOKEN'),
  intents: DiscordRuby::Constants::Intents::GUILDS
)
guild_id = ENV.fetch('GUILD_ID')

bot.on_command('dr-ping') do |interaction|
  interaction.reply(content: 'Pong!', ephemeral: true)
end

bot.on_ready do |_payload|
  bot.register_guild_command(guild_id, {
    name: 'dr-ping',
    description: 'Check whether DiscordRuby is responding'
  })
  puts 'Registered /dr-ping in the test server.'
end

bot.on('error') { |error| warn error.message }
bot.run!
```

Run `bundle exec ruby -Ilib quickstart.rb`. In the test server, invoke `/dr-ping`. The reply should be visible only to you. Keep the process running while invoking the command.

`register_guild_command` registers one command using the application ID provided by the Gateway. The `on_ready` callback makes that ID available. This example registers again whenever the callback receives a new READY event. In a deployed bot, you can move command registration into a separate deployment script.

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| `cannot load such file -- discord_ruby` | Run from the repository root with `-Ilib`. |
| Missing `TOKEN` or `GUILD_ID` | Set both in the same shell before running the script. |
| Authentication failure or HTTP 401 | Check that `TOKEN` contains the bot token for this application and that it has not been reset. |
| HTTP 403 | Check the bot's installation, role, and channel permissions. Enabling a Gateway intent does not grant channel access. |
| The slash command is missing | Verify the server ID, application installation, and registration output. Register in the test server before trying global commands. |
| A message handler sees no text | For a prefix bot, request the Message Content intent in code and configure it for the app in the portal. The slash example above does not need it. |
| A card returns an invalid body error | Start with one `TextDisplay`. Add other components one at a time and check [V2 placement rules](messages.md#components-v2). |

Continue with [messages and Components V2](messages.md) or [interactions and events](interactions.md).
