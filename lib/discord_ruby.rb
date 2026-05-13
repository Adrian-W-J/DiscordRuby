require 'json'
require 'net/http'
require 'uri'
require 'openssl'

require_relative 'discord_ruby/version'
require_relative 'discord_ruby/cache'
require_relative 'discord_ruby/command_registry'
require_relative 'discord_ruby/interaction'
require_relative 'discord_ruby/embeds'
require_relative 'discord_ruby/components'
require_relative 'discord_ruby/collectors'
require_relative 'discord_ruby/api_client'
require_relative 'discord_ruby/gateway'
require_relative 'discord_ruby/bot'

module DiscordRuby
  API_BASE = 'https://discord.com/api/v10'.freeze
end
