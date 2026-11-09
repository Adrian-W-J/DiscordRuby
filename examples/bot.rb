#!/usr/bin/env ruby

require_relative '../lib/discord_ruby'









env_path = File.join(File.dirname(__FILE__), '.env')
if File.exist?(env_path)
  File.readlines(env_path).each do |line|
    line = line.strip
    next if line.empty? || line.start_with?('#')
    key, value = line.split('=', 2)
    ENV[key] ||= value if key && value && !value.empty?
  end
  puts "Loaded environment from .env"
end

TOKEN = ENV['TOKEN']

if TOKEN.nil? || TOKEN.empty?
  puts "ERROR: No token provided!"
  puts "Please set the TOKEN environment variable:"
  puts "  Windows (PowerShell): \$env:TOKEN=\"your_token_here\""
  puts "  Linux/Mac: export TOKEN=your_token_here"
  exit 1
end

puts "Starting bot..."

ALL_INTENTS = 32767 | (1 << 15) | (1 << 16) | (1 << 20) | (1 << 21)
puts "Intents: #{ALL_INTENTS}"
puts "DEBUG mode is ENABLED" if ENV['DEBUG']
puts "TIP: Enable DEBUG=true for more detailed gateway logs if it doesn't connect."
bot = DiscordRuby::Bot.new(token: TOKEN, intents: ALL_INTENTS)

bot.on_ready do |ready|
  puts "Ready: #{ready['user']['username']}##{ready['user']['discriminator']}"
  puts "Bot ID: #{ready['user']['id']}"
  bot.set_activity("with Ruby models", type: 0)
end

bot.on_message do |message|

  puts "[DEBUG] Received message from #{message.author.tag}: '#{message.content}'"

  if message.content.nil? || (message.content.empty? && message.attachments.empty? && message.embeds.empty?)
    puts "  [WARN] Message content is EMPTY. Did you enable MESSAGE CONTENT INTENT in the Developer Portal?"
  end

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
  elsif message.content == '!cv2'
    message.add_reaction("❌")
  elsif message.content == '!roles'
    if message.guild
      roles = message.guild.roles.map(&:name).join(', ')
      message.reply(content: "Roles in this guild: #{roles}")
    else
      message.reply(content: "This command only works in a server.")
    end
  elsif message.content == '!register'
    begin

      message.add_reaction("✅")



      puts "  [INFO] Registering slash commands..."
      bot.bulk_overwrite_global_commands([
        { name: 'ping', description: 'Simple ping command' },
        { name: 'echo', description: 'Echoes back your text', options: [
          { name: 'text', description: 'The text to echo', type: 3, required: true }
        ]},
        { name: 'member_info', description: 'Shows info about you' },
        { name: 'cv2', description: 'Showcases all Components V2 features' }
      ])
      puts "  [INFO] Registration successful."
    rescue => e
      puts "  [ERROR] Registration failed: #{e.message}"
      message.reply(content: "Failed to register commands: #{e.message}")
    end
  end
end

bot.on_command('ping') do |interaction|
  puts "[DEBUG] Received /ping command"
  interaction.reply(content: 'Pong from a rich interaction!', ephemeral: true)
end

bot.on_command('echo') do |interaction|
  puts "[DEBUG] Received /echo command"
  text = interaction.get_option('text')
  interaction.reply(content: "You said: #{text}")
end

bot.on_command('member_info') do |interaction|
  puts "[DEBUG] Received /member_info command"
  member = interaction.member
  interaction.reply(content: "Your nick: #{member.nick || 'None'}, Joined at: #{member.joined_at}")
end

bot.on_command('cv2') do |interaction|
  section = DiscordRuby::Component::Section.new
  section.add_text("Try the button to update this card.")
  section.set_accessory(DiscordRuby::Component::Button.new(style: 1, label: "Update card", custom_id: "cv2_btn"))

  gallery = DiscordRuby::Component::MediaGallery.new
  gallery.add_item(url: "https://www.ruby-lang.org/images/header-ruby-logo.png", description: "Ruby logo")

  card = DiscordRuby::Component::Container.build(accent_color: 0xCC342D) do |container|
    container.add_text("## DiscordRuby Components V2")
    container.add_component(section)
    container.add_component(DiscordRuby::Component::Separator.new)
    container.add_component(gallery)
  end

  interaction.reply(components: [card])
end

bot.on_component('cv2_btn') do |interaction|
  interaction.update(components: [DiscordRuby::Component::TextDisplay.new("The card was updated.")])
end

bot.on('error') do |error|
  warn "Gateway error: #{error}"
end

bot.run!
