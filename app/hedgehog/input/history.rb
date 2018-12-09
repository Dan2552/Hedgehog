module Hedgehog
  module Input
    class History
      def initialize(limit: 50)
        @limit = limit
        reset_index!
      end

      # Returns the previous history item.
      #
      def up
        @current_index = current_index - 1
        @current_index = 0 if current_index < 0
        store[current_index]
      end

      # Returns the next history item.
      #
      # If the index is past the total elements, will instead return nil.
      #
      def down
        return nil if current_index >= store.count
        @current_index = current_index + 1
        store[current_index]
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
