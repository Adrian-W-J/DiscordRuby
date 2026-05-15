module DiscordRuby
  class BaseManager
    attr_reader :bot

    def initialize(bot)
      @bot = bot

    end
  end

  class CachedManager < BaseManager
    attr_reader :cache, :model_class

    def initialize(bot, model_class, limit: 1000)
      super(bot)
      @model_class = model_class
      @cache = Cache.new(limit: limit)

    end

    def resolve(id_or_object)
      return id_or_object if id_or_object.is_a?(@model_class)
      @cache.get(id_or_object.to_s)
    end

    def resolve_id(id_or_object)
      return id_or_object.id if id_or_object.is_a?(@model_class)
      id_or_object.to_s
    end

    def add(data, cache: true)
      obj = @model_class.new(@bot, data)
      @cache.set(obj.id, obj) if cache
      obj
    end

    def fetch(id)
      raise NotImplementedError
    end
  end
end
