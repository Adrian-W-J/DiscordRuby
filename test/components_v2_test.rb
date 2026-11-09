require 'minitest/autorun'
require 'discord_ruby'

class ComponentsV2Test < Minitest::Test
  Components = DiscordRuby::Component
  Flags = DiscordRuby::Interaction::MessageFlags

  class RecordingBot < DiscordRuby::Bot
    attr_reader :last_request

    def request(method, path, **options)
      @last_request = {method: method, path: path, **options}
      {'id' => 'message', 'flags' => options.dig(:body, :flags)}
    end
  end

  def setup
    @bot = RecordingBot.new(token: 'fake-token')
  end

  def test_builder_channel_send_and_legacy_message
    data = DiscordRuby::Builders::MessageBuilder.build do |builder|
      builder.container(accent_color: 0xCC342D) do |container|
        container.add_text('Ready')
        container.add_row { |row| row.add_button(label: 'Go', custom_id: 'go') }
      end
    end
    message = @bot.send_message('channel', **data, flags: Flags::SUPPRESS_NOTIFICATIONS)
    assert message.components_v2?
    assert_equal Flags::IS_COMPONENTS_V2 | Flags::SUPPRESS_NOTIFICATIONS, body[:flags]
    assert_equal [10, 1], body[:components].first[:components].map { |child| child[:type] }
    refute body.key?(:embeds)

    legacy = DiscordRuby::Builders::MessageBuilder.build do |builder|
      builder.content('legacy').add_button(label: 'Go', custom_id: 'go')
    end
    @bot.send_message('channel', **legacy)
    assert_equal 'legacy', body[:content]
    refute body.key?(:flags)
  end

  def test_channel_edit_converts_legacy_and_accepts_raw_json_hashes
    components = [{'type' => 17, 'components' => [{'type' => 10, 'content' => 'Updated'}]}]
    @bot.edit_message('channel', 'message', components: components)
    assert_equal :patch, @bot.last_request[:method]
    assert_equal Flags::IS_COMPONENTS_V2, body[:flags]
    assert_nil body.fetch(:content)
    assert_nil body.fetch(:poll)
    assert_equal [], body[:embeds]
    assert_equal [], body[:sticker_ids]
    assert_equal 'Updated', body[:components].first[:components].first[:content]
    assert_equal 17, components.first['type']

    @bot.edit_message('channel', 'message', components: [], flags: 0)
    assert_equal({components: [], flags: 0}, body)
  end

  def test_interaction_replies_followups_and_edits
    interaction = DiscordRuby::Interaction.from_data(@bot, interaction_data(2))
    interaction.reply(components: [text], ephemeral: true)
    assert_equal 4, body[:type]
    assert_equal Flags::IS_COMPONENTS_V2 | Flags::EPHEMERAL, body[:data][:flags]
    assert interaction.replied?

    interaction.edit_reply(components: [text])
    assert_match %r{/messages/@original\z}, @bot.last_request[:path]
    assert_equal Flags::IS_COMPONENTS_V2, body[:flags]
    assert_nil body.fetch(:content)

    interaction.follow_up(components: [text], ephemeral: true)
    assert_equal Flags::IS_COMPONENTS_V2 | Flags::EPHEMERAL, body[:flags]
    refute body.key?(:content)
  end

  def test_button_update_and_deferred_reply
    interaction = DiscordRuby::Interaction.from_data(@bot, interaction_data(3))
    interaction.update(components: [text])
    assert_equal 7, body[:type]
    assert_equal Flags::IS_COMPONENTS_V2, body[:data][:flags]

    command = DiscordRuby::Interaction.from_data(@bot, interaction_data(2))
    command.defer_reply(ephemeral: true)
    assert_equal({type: 5, data: {flags: Flags::EPHEMERAL}}, body)
    command.edit_reply(components: [text])
    assert_equal Flags::IS_COMPONENTS_V2, body[:flags]
  end

  def test_webhook_send_and_edit_request_components
    @bot.execute_webhook('webhook', 'test', {components: [text]}, wait: true, thread_id: 'thread')
    assert_equal({wait: true, thread_id: 'thread', with_components: true}, @bot.last_request[:params])
    assert_equal Flags::IS_COMPONENTS_V2, body[:flags]
    @bot.edit_webhook_message('webhook', 'test', 'message', {components: [text]})
    assert_equal({with_components: true}, @bot.last_request[:params])
    assert_equal [], body[:embeds]
  end

  def test_rejects_conflicting_fields_and_invalid_layouts_before_sending
    assert_raises(ArgumentError) { @bot.send_message('channel', 'legacy text', components: [text]) }
    assert_raises(ArgumentError) { @bot.send_message('channel', components: [Components::Section.new]) }
    assert_raises(ArgumentError) { @bot.send_message('channel', components: Array.new(41) { text }) }
    duplicate_button = Components::Button.new(style: 1, custom_id: 'duplicate', label: 'Duplicate')
    row = Components::ActionRow.new(duplicate_button, duplicate_button)
    assert_raises(ArgumentError) { @bot.send_message('channel', components: [text, row]) }
    assert_nil @bot.last_request
  end

  def test_file_component_uses_attachment_reference
    file = Components::File.new(url: 'attachment://report.txt')
    @bot.send_message('channel', components: [file], files: {'report.txt' => "data\x00".b})
    assert_equal({url: 'attachment://report.txt'}, body[:components].first[:file])
    assert_equal "data\x00".b, @bot.last_request[:files]['report.txt']
    bad_file = Components::File.new(url: 'https://example.com/report.txt')
    assert_raises(ArgumentError) { @bot.send_message('channel', components: [bad_file]) }
  end

  def test_labeled_modal_and_legacy_modal_submission
    input = Components::TextInput.new(custom_id: 'answer', style: 1)
    label = Components::Label.new(label: 'Answer', component: input)
    modal = Components::Modal.new(title: 'Question', custom_id: 'question', components: [label, text])
    command = DiscordRuby::Interaction.from_data(@bot, interaction_data(2))
    command.show_modal(modal)
    assert_equal 9, body[:type]
    assert_equal 18, body[:data][:components].first[:type]
    refute body[:data].key?(:flags)

    data = interaction_data(5)
    data['data']['components'] = [
      {'type' => 18, 'component' => {'custom_id' => 'answer', 'value' => 'yes'}},
      {'type' => 1, 'components' => [{'custom_id' => 'legacy', 'value' => 'ok'}]},
      {'type' => 18, 'component' => {'custom_id' => 'select', 'values' => ['one']}}
    ]
    result = DiscordRuby::Interaction.from_data(@bot, data)
    assert_equal({'answer' => 'yes', 'legacy' => 'ok', 'select' => ['one']}, result.fields)
  end

  private

  def interaction_data(type)
    {'id' => 'interaction', 'application_id' => 'app', 'type' => type,
     'user' => {'id' => 'user'}, 'data' => {}, 'token' => 'fake-interaction-token'}
  end

  def text
    Components::TextDisplay.new('Ready')
  end

  def body
    @bot.last_request.fetch(:body)
  end
end
