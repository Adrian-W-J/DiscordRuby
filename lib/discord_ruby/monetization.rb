module DiscordRuby
  class SKU < BaseModel
    attr_reader :type, :dependent_sku_id, :application_id, :name, :slug, :flags

    def initialize(bot, data)
      super
      @flags = Bitfield.new(data['flags'] || 0)
    end
  end

  class Entitlement < BaseModel
    attr_reader :sku_id, :application_id, :user_id, :promotion_id, :type, :deleted, :starts_at, :ends_at, :guild_id

    def delete
      @bot.delete_test_entitlement(@application_id, id)
    end
  end

  class ApplicationEntitlementManager < CachedManager
    attr_reader :application_id

    def initialize(bot, application_id)
      super(bot, Entitlement)
      @application_id = application_id
    end

    def fetch_all(user_id: nil, sku_ids: nil, before: nil, after: nil, limit: 100, guild_id: nil, exclude_ended: nil)
      data = @bot.list_entitlements(@application_id, user_id: user_id, sku_ids: sku_ids, before: before, after: after, limit: limit, guild_id: guild_id, exclude_ended: exclude_ended)
      data.map { |e| add(e) }
    end

    def create_test(sku_id, owner_id, owner_type)
      data = @bot.create_test_entitlement(@application_id, sku_id, owner_id, owner_type)
      add(data)
    end
  end
end
