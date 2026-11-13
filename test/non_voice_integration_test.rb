require 'minitest/autorun'
require 'discord_ruby'
require 'timeout'

class NonVoiceIntegrationTest < Minitest::Test
  class RecordingBot < DiscordRuby::Bot
    attr_reader :calls

    def initialize(**options)
      super
      @calls = []
    end

    def request(method, path, **options)
      @calls << [method, path, options]
      {'id' => '7', 'channel_id' => '12'}
    end
  end

  def test_message_manager_reuses_cache_and_can_force_a_fetch
    bot = RecordingBot.new(token: 'fake')
    channel = DiscordRuby::Channel.new(bot, {'id' => '12'})
    message = channel.messages.create('Hello')
    assert_instance_of DiscordRuby::Message, message
    assert_same message, channel.messages.fetch('7')
    assert_equal 1, bot.calls.size
    refute_same message, channel.messages.fetch('7', force: true, cache: false)
    assert_equal [:get, '/channels/12/messages/7'], bot.calls.last.first(2)
    channel.messages.delete('7')
    assert_nil bot.messages.get('7')
  end

  def test_webhook_messages_preserve_thread_and_upload_options
    bot = RecordingBot.new(token: 'fake')
    webhook = DiscordRuby::Webhook.new(bot, {'id' => '8', 'token' => 'fake'})
    assert_instance_of DiscordRuby::Message, webhook.send('Hello', thread_id: '9', files: {'test.txt' => 'hi'})
    assert_equal({wait: true, thread_id: '9'}, bot.calls.last[2][:params])
    assert_equal({'test.txt' => 'hi'}, bot.calls.last[2][:files])
    assert_instance_of DiscordRuby::Message, webhook.edit_message('7', 'Edited', thread_id: '9')
    assert_equal 'Edited', bot.calls.last[2].dig(:body, :content)
    webhook.delete_message('7', thread_id: '9')
    assert_equal({thread_id: '9'}, bot.calls.last[2][:params])
  end

  def test_cache_expiry_and_sweeping
    clock = Class.new(DiscordRuby::Cache) do
      attr_accessor :now
    end
    cache = clock.new(ttl: 5, limit: 2)
    cache.now = 0
    cache.set('old', 1)
    cache.now = 3
    cache.set('new', 2)
    cache.now = 5
    assert_equal 1, cache.sweep
    assert_nil cache.get('old')
    assert_equal [2], cache.values
  end

  def test_pins_are_paginated_into_message_models
    bot = RecordingBot.new(token: 'fake')
    bot.define_singleton_method(:request) do |method, path, **options|
      @calls << [method, path, options]
      before = options.dig(:params, :before)
      {'items' => [{'pinned_at' => 'cursor', 'message' => {'id' => before ? '2' : '1'}}],
       'has_more' => before.nil?}
    end
    channel = DiscordRuby::Channel.new(bot, {'id' => '12'})
    assert_equal %w[1 2], channel.messages.fetch_pinned.map(&:id)
    assert_equal [:get, '/channels/12/messages/pins', {params: {limit: 50, before: 'cursor'}}], bot.calls.last
  end

  def test_reaction_collector_filters_and_stops_at_limit
    bot = RecordingBot.new(token: 'fake')
    collector = DiscordRuby::ReactionCollector.new(bot, '7', max: 1, filter: ->(data) { data['user_id'] == '8' })
    received = []
    finished = Queue.new
    collector.on_collect { |data| received << data }
    collector.on_end { |items, reason| finished << [items, reason] }
    bot.gateway.send(:dispatch, 'MESSAGE_REACTION_ADD', {'message_id' => '7', 'user_id' => '9'})
    event = {'message_id' => '7', 'user_id' => '8'}
    bot.gateway.send(:dispatch, 'MESSAGE_REACTION_ADD', event)
    assert_equal [[event], 'limit'], Timeout.timeout(2) { finished.pop }
    assert collector.ended?
    assert_equal [event], received
    collector.on_end { |items, reason| assert_equal [[event], 'limit'], [items, reason] }
  end

  def test_collector_expires_and_notifies_once
    bot = RecordingBot.new(token: 'fake')
    collector = DiscordRuby::MessageCollector.new(bot, '12', idle: 0.01)
    finished = Queue.new
    collector.on_end { |items, reason| finished << [items, reason] }
    assert_equal [[], 'idle'], Timeout.timeout(2) { finished.pop }
    collector.end_collector
    assert finished.empty?
  end

  def test_framework_registers_and_dispatches_a_command
    bot = RecordingBot.new(token: 'fake')
    framework = DiscordRuby::Commands::Framework.new(bot)
    command = framework.slash_command('search', 'Search docs') do |builder|
      builder.string_option(name: 'query', description: 'Search text', required: true)
      builder.execute { |interaction| interaction.reply(content: interaction.get_option('query')) }
    end
    assert_equal 'query', command.to_h[:options].first[:name]
    bot.instance_variable_set(:@application_id, '42')
    framework.sync_commands('123')
    assert_equal '/applications/42/guilds/123/commands', bot.calls.last[1]
    bot.send(:handle_interaction_create, {
      'id' => '1', 'type' => 2, 'token' => 'fake',
      'data' => {'name' => 'search', 'options' => [{'name' => 'query', 'value' => 'Ruby'}]}
    })
    assert_equal 'Ruby', bot.calls.last[2].dig(:body, :data, :content)
  end

  def test_shard_identify_includes_the_configured_pair
    bot = RecordingBot.new(token: 'fake', shard: [1, 3])
    assert_equal [1, 3], bot.gateway.send(:identify_payload)[:shard]
    refute RecordingBot.new(token: 'fake').gateway.send(:identify_payload).key?(:shard)
    assert_raises(ArgumentError) { RecordingBot.new(token: 'fake', shard: [3, 3]) }
  end

  def test_replacing_cached_entry_preserves_other_entries
    cache = DiscordRuby::Cache.new(limit: 2)
    cache.set('first', 1)
    cache.set('second', 2)
    cache.set('second', 3)
    assert_equal [1, 3], cache.values
    cache.set('third', 4)
    assert_equal ['second', 'third'], cache.keys
    disabled = DiscordRuby::Cache.new(limit: 0)
    disabled.set('first', 1)
    assert_equal 0, disabled.size
  end

  def test_modal_upload_preserves_attachment_ids_and_resolves_models
    component = DiscordRuby::Component::FileUpload.new(custom_id: 'report', file_types: ['.txt'])
    label = DiscordRuby::Component::Label.new(label: 'Report', component: component)
    assert_equal({type: 19, custom_id: 'report', file_types: ['.txt']}, label.to_h[:component])
    bot = RecordingBot.new(token: 'fake')
    interaction = DiscordRuby::Interaction.from_data(bot, {
      'type' => 5, 'data' => {
        'components' => [{'component' => {'type' => 19, 'custom_id' => 'report', 'values' => ['7']}}],
        'resolved' => {'attachments' => {'7' => {'id' => '7', 'filename' => 'report.txt'}}}
      }
    })
    assert_equal ['7'], interaction.fields['report']
    assert_equal 'report.txt', interaction.files('report').first.filename
  end
end
