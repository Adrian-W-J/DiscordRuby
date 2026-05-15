module DiscordRuby
  class Poll < BaseModel
    attr_reader :question, :answers, :expiry, :allow_multiselect, :layout_type, :results

    def initialize(bot, data)
      super
      @answers = data['answers']&.map { |a| PollAnswer.new(bot, a) } || []
      @results = PollResults.new(bot, data['results']) if data['results']
    end

    def question_text
      @question['text']
    end

    def expired?
      @expiry && Time.parse(@expiry) < Time.now
    end

    def end
      @bot.api.expire_poll(guild_id, channel_id, message_id)
    end
  end

  class PollAnswer < BaseModel
    attr_reader :answer_id, :poll_media

    def text
      @poll_media['text']
    end

    def emoji
      @poll_media['emoji']
    end
  end

  class PollResults < BaseModel
    attr_reader :is_finalized, :answer_counts

    def initialize(bot, data)
      super
      @answer_counts = data['answer_counts'] || []
    end

    def get_count_for(answer_id)
      @answer_counts.find { |c| c['id'] == answer_id }&.[]('count') || 0
    end
  end
end
