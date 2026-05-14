#!/usr/bin/env ruby

require_relative '../lib/discord_ruby'

TOKEN = ENV.fetch('DISCORD_BOT_TOKEN')

bot = DiscordRuby::Bot.new(token: TOKEN, intents: 32767) # All intents for demo

bot.on_ready do |ready|
  puts "Ready: #{ready['user']['username']}##{ready['user']['discriminator']}"
  bot.set_activity("with Ruby models", type: 0)
end

bot.on_message do |message|
  next if message.author.bot_user

  if message.content == '!ping'
    message.reply(content: 'Pong!')
  elsif message.content == '!hello'
    message.reply(content: "Hello, #{message.author.username}!")
  elsif message.content == '!timeout'
    message.member.timeout(Time.now + 60)
    message.reply(content: "Timed you out for 60 seconds!")
  elsif message.content == '!poll'
    message.reply(content: "Favorite language?", poll: {
      question: { text: "What is your favorite programming language?" },
      answers: [
        { answer_id: 1, poll_media: { text: "Ruby", emoji: { name: "💎" } } },
        { answer_id: 2, poll_media: { text: "JavaScript" } },
        { answer_id: 3, poll_media: { text: "Python" } }
      ],
      duration: 1
    })
  end
end

bot.on_command('ping') do |interaction|
  interaction.reply(content: 'Pong from a rich interaction!', ephemeral: true)
end

bot.on_command('echo') do |interaction|
  text = interaction.get_option('text')
  interaction.reply(content: "You said: #{text}")
end

bot.on_command('member_info') do |interaction|
  member = interaction.member
  interaction.reply(content: "Your nick: #{member.nick || 'None'}, Joined at: #{member.joined_at}")
end

bot.on_message do |message|
  next if message.author.bot_user

  if message.content == '!roles'
    roles = message.guild.roles.map(&:name).join(', ')
    message.reply(content: "Roles in this guild: #{roles}")
  end
end

bot.on('error') do |error|
  warn "Gateway error: #{error}"
end

bot.run!
