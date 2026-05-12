#!/usr/bin/env ruby

require_relative '../lib/discord_ruby'

TOKEN = ENV.fetch('DISCORD_BOT_TOKEN')

bot = DiscordRuby::Bot.new(token: TOKEN, intents: 513)

bot.on('READY') do |data|
  puts "Ready: #{data['user']['username']}##{data['user']['discriminator']}"
end

bot.on('MESSAGE_CREATE') do |event|
  next if event['author']['bot']

  if event['content'] == '!ping'
    bot.send_message(event['channel_id'], 'Pong!')
  elsif event['content'] == '!hello'
    bot.send_message(event['channel_id'], "Hello, #{event['author']['username']}!")
  end
end

bot.on_command('ping') do |interaction|
  bot.reply(interaction, content: 'Pong from a slash command!')
end

bot.on('error') do |error|
  warn "Gateway error: #{error}"
end

bot.run!
