module DiscordRuby
  module Utils
    class Collection < Hash
      def initialize(entries = nil)
        super()
        entries&.each { |k, v| self[k] = v }
      end

      def first(amount = nil)
        return values.first unless amount
        values.first(amount)
      end

      def last(amount = nil)
        return values.last unless amount
        values.last(amount)
      end

      def find(&block)
        values.find(&block)
      end

      def filter(&block)
        self.class.new(select(&block))
      end

      def map_values(&block)
        values.map(&block)
      end

      def some?(&block)
        values.any?(&block)
      end

      def every?(&block)
        values.all?(&block)
      end

      def random
        values.sample
      end

      def difference(other)
        self.class.new(reject { |k, _| other.key?(k) })
      end

      def intersect(other)
        self.class.new(select { |k, _| other.key?(k) })
      end

      def equals(other)
        return false unless other.is_a?(Collection)
        return false if size != other.size
        all? { |k, v| other[k] == v }
      end

      def sort(&block)
        self.class.new(super(&block).to_h)
      end

      def sweep(&block)
        previous_size = size
        delete_if(&block)
        previous_size - size
      end

      def partition(&block)
        res = super(&block)
        [self.class.new(res[0].to_h), self.class.new(res[1].to_h)]
      end

      def flat_map(&block)
        values.flat_map(&block)
      end

      def reduce(initial, &block)
        values.reduce(initial, &block)
      end

      def each_key(&block)
        keys.each(&block)
      end

      def each_value(&block)
        values.each(&block)
      end

      def reverse
        self.class.new(to_a.reverse.to_h)
      end

      def clone
        self.class.new(self)
      end

      def concat(*others)
        others.each { |other| merge!(other) }
        self
      end

      def ensure(key, &block)
        return self[key] if key?(key)
        val = yield
        self[key] = val
      end

      def keys_array
        keys
      end

      def values_array
        values
      end
    end
  end
end
