module Hedgehog
  module Input
    class History
      def initialize(limit: 50)
        @limit = limit
        reset_index!
      end

      # Returns the previous history item.
      #
      # - parameter matching: Partial match string. When supplied, only results
      #   that include this value will be returned.
      #
      def up(matching: nil)
        @current_index = current_index - 1
        @current_index = 0 if current_index < 0
        result = store[current_index]

        return if result.nil?

        if matching && !result.include?(matching)
          return up(matching: matching)
        end

        result
      end

      # Returns the next history item.
      #
      # If the index is past the total elements, will instead return nil.
      #
      # - parameter matching: Partial match string. When supplied, only results
      #   that include this value will be returned.
      #
      def down(matching: nil)
        return nil if current_index >= store.count
        @current_index = current_index + 1
        result = store[current_index]

        return if result.nil?

        if matching && !result.include?(matching)
          return down(matching: matching)
        end

        result
      end

      def <<(new_element)
        return if new_element.strip.length < 1
        return if store.last == new_element
        store << new_element
        store.delete_at(0) if store.count > limit
        reset_index!
      end

      private

      attr_reader :limit,
                  :current_index

      def store
        @store ||= []
      end

      def reset_index!
        @current_index = store.count
      end
    end
  end
end
