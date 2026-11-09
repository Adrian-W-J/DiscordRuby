module DiscordRuby
  module MessagePayload
    V2_FLAG = Interaction::MessageFlags::IS_COMPONENTS_V2
    V2_TYPES = [9, 10, 11, 12, 13, 14, 17].freeze
    ROOT_TYPES = [1, 9, 10, 12, 13, 14, 17].freeze
    SELECT_TYPES = [3, 5, 6, 7, 8].freeze
    LEGACY_FIELDS = { content: nil, embeds: [], poll: nil, sticker_ids: [] }.freeze

    def self.build(data, edit: false, channel: false)
      payload = data.transform_keys(&:to_sym)
      payload[:embeds] = payload[:embeds].map(&:to_h) if payload[:embeds]
      components = payload[:components]
      nodes = []
      if components
        raise ArgumentError, 'components must be an array' unless components.is_a?(Array)
        payload[:components] = components.map { |component| serialize(component, nodes) }
      end

      flags = payload[:flags] || 0
      return payload if (flags & V2_FLAG).zero? && nodes.none? { |node| V2_TYPES.include?(node[:type]) }

      if !edit && nodes.empty?
        raise ArgumentError, 'a Components V2 message needs at least one component'
      end
      validate_layout(payload[:components], nodes) if components
      LEGACY_FIELDS.each do |field, empty|
        value = payload.delete(field)
        if !value.nil? && value != empty && !(field == :content && value == '')
          raise ArgumentError, "#{field} is incompatible with Components V2. Use components for the message body."
        end
        payload[field] = empty if edit && (field != :sticker_ids || channel)
      end
      payload[:flags] = flags | V2_FLAG
      payload
    end

    def self.serialize(component, nodes)
      unless component.respond_to?(:to_h) && (data = component.to_h).is_a?(Hash)
        raise ArgumentError, 'each component must be a hash or a component builder'
      end

      node = data.transform_keys(&:to_sym)
      nodes << node
      if node.key?(:components)
        children = node[:components]
        raise ArgumentError, 'nested components must be an array' unless children.is_a?(Array)
        node[:components] = children.map { |child| serialize(child, nodes) }
      end
      node[:accessory] = serialize(node[:accessory], nodes) if node[:accessory]
      node
    end
    private_class_method :serialize

    def self.validate_layout(roots, nodes)
      raise ArgumentError, 'Components V2 messages support at most 40 components' if nodes.size > 40

      unless roots.all? { |node| ROOT_TYPES.include?(node[:type]) }
        raise ArgumentError, 'invalid top-level Components V2 component'
      end

      custom_ids = nodes.filter_map { |node| node[:custom_id] }
      raise ArgumentError, 'duplicate component custom_id' if custom_ids.uniq.size != custom_ids.size

      nodes.each do |node|
        types = (node[:components] || []).map { |child| child[:type] }
        if node[:accessory] && node[:type] != 9
          raise ArgumentError, 'only Sections support an accessory'
        end
        valid = case node[:type]
                when 1
                  (types.size.between?(1, 5) && types.all?(2)) ||
                    (types.size == 1 && SELECT_TYPES.include?(types.first))
                when 9
                  types.size.between?(1, 3) && types.all?(10) &&
                    [2, 11].include?(node.dig(:accessory, :type))
                when 12
                  node[:items].is_a?(Array) && node[:items].size.between?(1, 10)
                when 13
                  file = node[:file]
                  url = file[:url] || file['url'] if file.is_a?(Hash)
                  url.is_a?(String) && url.match?(%r{\Aattachment://.+\z})
                when 17
                  !types.empty? && types.all? { |type| ROOT_TYPES.include?(type) && type != 17 }
                else
                  types.empty?
                end
        raise ArgumentError, "invalid Components V2 layout for component type #{node[:type]}" unless valid
      end
    end
    private_class_method :validate_layout
  end
end
