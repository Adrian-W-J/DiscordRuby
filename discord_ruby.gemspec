require_relative 'lib/discord_ruby/version'

Gem::Specification.new do |spec|
  spec.name          = 'discord_ruby'
  spec.version       = DiscordRuby::VERSION
  spec.authors       = ['DiscordRuby Author']
  spec.email         = ['support@example.com']

  spec.summary       = 'A lightweight Discord API wrapper for Ruby.'
  spec.description   = 'DiscordRuby provides REST and gateway helpers for building Discord bots in Ruby.'
  spec.homepage      = 'https://github.com/yourusername/discord_ruby'
  spec.license       = 'MIT'

  spec.files = Dir.glob(['lib/**/*.rb', 'docs/**/*.md']) + ['README.md', 'Gemfile', 'discord_ruby.gemspec', 'LICENSE']
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'websocket-client-simple', '~> 0.5'
end
