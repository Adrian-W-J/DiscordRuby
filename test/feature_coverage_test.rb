require 'minitest/autorun'
require 'discord_ruby'

class FeatureCoverageTest < Minitest::Test
  class RecordingBot < DiscordRuby::Bot
    attr_reader :last_request

    def request(method, path, **options)
      @last_request = [method, path, options]
      {'id' => '123', 'items' => [{'id' => '456', 'name' => 'party'}]}
    end
  end

  def setup
    @bot = RecordingBot.new(token: 'fake')
  end

  def test_autocomplete_dispatches_nested_focus_to_the_correct_handler
    @bot.on_command('search') { flunk 'autocomplete reached the command handler' }
    @bot.on_autocomplete('search') do |interaction|
      assert_equal 'ruby', interaction.focused_option['value']
      interaction.respond([{name: 'Ruby', value: 'ruby'}])
      assert interaction.replied?
    end
    @bot.send(:handle_interaction_create, {
      'id' => '10', 'token' => 'fake', 'type' => 4,
      'data' => {'name' => 'search', 'options' => [
        {'name' => 'docs', 'options' => [{'name' => 'query', 'value' => 'ruby', 'focused' => true}]}
      ]}
    })
    assert_equal [:post, '/interactions/10/fake/callback', {
      body: {type: 8, data: {choices: [{name: 'Ruby', value: 'ruby'}]}}
    }], @bot.last_request
  end

  def test_user_install_metadata_and_context_menu_target
    interaction = DiscordRuby::Interaction.from_data(@bot, {
      'type' => 2, 'locale' => 'fr', 'context' => 2,
      'authorizing_integration_owners' => {'1' => '55'},
      'entitlements' => [{'sku_id' => '99'}],
      'data' => {'type' => 3, 'target_id' => '42', 'resolved' => {
        'messages' => {'42' => {'id' => '42', 'content' => 'Selected message'}}
      }}
    })
    assert_equal 'Selected message', interaction.target.content
    assert_equal 'fr', interaction.locale
    assert_equal '55', interaction.authorizing_integration_owners['1']
    assert_equal '99', interaction.entitlements.first['sku_id']

    payload = DiscordRuby::Builders::SlashCommandBuilder.new
      .name('Save Message').type(3).integration_types(1).contexts(1, 2).to_h
    assert_equal({name: 'Save Message', type: 3, integration_types: [1], contexts: [1, 2]}, payload)
    option = DiscordRuby::Builders::SlashCommandBuilder.new
      .string_option(name: 'query', description: 'Search text', name_localizations: {'fr' => 'recherche'})
      .to_h[:options].first
    assert_equal({'fr' => 'recherche'}, option[:name_localizations])
  end

  def test_sticker_upload_uses_multipart_form_fields
    @bot.create_guild_sticker('1', name: 'Party', description: '', tags: 'party',
                             file: 'bytes', filename: 'party.png', reason: 'New sticker')
    method, path, data = @bot.last_request
    assert_equal [:post, '/guilds/1/stickers'], [method, path]
    assert_equal ['file', 'bytes', {filename: 'party.png', content_type: 'image/png'}], data[:form].last
    assert_equal 'New%20sticker', data[:headers]['X-Audit-Log-Reason']
    assert_raises(ArgumentError) do
      @bot.create_guild_sticker('1', name: 'Party', description: '', tags: 'party', file: 'bytes', filename: 'file.exe')
    end
  end

  def test_forum_posts_and_message_forwarding
    text = DiscordRuby::Component::TextDisplay.new('New thread')
    channel = DiscordRuby::Channel.new(@bot, {'id' => '10'})
    channel.create_forum_post(name: 'Updates', message: {components: [text]}, applied_tags: ['11'])
    assert_equal '/channels/10/threads', @bot.last_request[1]
    assert_equal 32768, @bot.last_request[2].dig(:body, :message, :flags)
    assert_equal ['11'], @bot.last_request[2].dig(:body, :applied_tags)

    message = DiscordRuby::Message.new(@bot, {'id' => '20', 'channel_id' => '21', 'guild_id' => '22'})
    message.forward_to('23')
    assert_equal '/channels/23/messages', @bot.last_request[1]
    assert_equal({type: 1, channel_id: '21', message_id: '20', guild_id: '22'},
                 @bot.last_request[2].dig(:body, :message_reference))
  end

  def test_permission_edit_uses_bearer_and_application_emoji_unwraps_items
    @bot.edit_command_permissions('1', '2', '3', permissions: [], bearer_token: 'fake-oauth')
    assert_equal [:put, '/applications/1/guilds/2/commands/3/permissions',
                  {body: {permissions: []}, headers: {'Authorization' => 'Bearer fake-oauth'}}], @bot.last_request
    assert_equal 'party', @bot.list_application_emojis('1').first.name
    assert_equal '/applications/1/emojis', @bot.last_request[1]
  end

  def test_monetization_routes_and_purchase_buttons
    @bot.list_sku_subscriptions('1', user_id: '2', limit: 20)
    assert_equal [:get, '/skus/1/subscriptions', {params: {user_id: '2', limit: 20}}], @bot.last_request
    @bot.consume_entitlement('3', '4')
    assert_equal [:post, '/applications/3/entitlements/4/consume', {}], @bot.last_request
    row = DiscordRuby::Component::ActionRow.build { |builder| builder.add_button(style: 6, sku_id: '1') }
    assert_equal({type: 2, style: 6, sku_id: '1', disabled: false}, row.to_h[:components].first)
    assert_raises(ArgumentError) { DiscordRuby::Component::Button.new(style: 6, sku_id: '1', label: 'Buy').to_h }
  end

  def test_voice_state_sends_gateway_opcode_four
    outgoing = []
    @bot.gateway.define_singleton_method(:send_payload) { |opcode, data| outgoing << [opcode, data] }
    @bot.update_voice_state('guild', 'channel', self_mute: true)
    @bot.update_voice_state('guild', nil)
    assert_equal [
      [4, {guild_id: 'guild', channel_id: 'channel', self_mute: true, self_deaf: false}],
      [4, {guild_id: 'guild', channel_id: nil, self_mute: false, self_deaf: false}]
    ], outgoing
  end
end
