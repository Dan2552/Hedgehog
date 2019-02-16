module Hedgehog
  module Input
    class History
      # - parameter limit: The total amount of history items to keep. When
      #   at the maximum, the oldest will be dropped.
      # - parameter persistence_filepath: When provided, the history will be
      #   serialized at this path.
      #
      def initialize(limit: 1024 * 256, persistence_filepath: DEFAULT_FILEPATH)
        @limit = limit
        @persistence_filepath = persistence_filepath&.sub("~", ENV['HOME'])
        @loaded = false
      end

      # Returns the previous history item.
      #
      # - parameter matching: Partial match string. When supplied, only results
      #   that include this value will be returned.
      #
      def up(matching: nil)
        return nil if store.count == 0

        @current_index = current_index - 1
        @current_index = 0 if current_index < 0
        result = store[current_index]

        return if result.nil?

        if matching && !result.include?(matching)
          return nil if @current_index == 0
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
        return nil if store.count == 0
        return nil if current_index >= store.count
        @current_index = current_index + 1
        result = store[current_index]

        return if result.nil?

        if matching && !result.include?(matching)
          return down(matching: matching)
        end

        result
      end

      # Inserts a new history item. Index will be reset back to the last element
      # in the history.
      #
      # When inserting above the limit, the oldest element will be deleted.
      #
      def <<(new_element)
        new_element = new_element.strip
        return if new_element.length < 1
        return if store.last == new_element
        store << new_element
        store.delete_at(0) if store.count > limit
        reset_index!
        save_store
      end

      # Resets the index back to the last element in the history.
      #
      def reset_index!
        return unless @loaded
        @current_index = store.count
      end

      # Get a suggestion based on the beginning of a command that has been
      # previously executed.
      #
      # - parameter start: The beginning of the command.
      #
      def suggestion_for(start)
        store.reverse_each do |element|
          return element if element.start_with?(start)
        end
        nil
      end

      private

      DEFAULT_FILEPATH = "~/.local/share/hedgehog/hedgehog_history".freeze

      attr_reader :limit

      def current_index
        @current_index ||= reset_index!
      end

      def store
        @store ||= load_store
      end

      def load_store
        @loaded = true

        if @persistence_filepath && File.exists?(@persistence_filepath)
          YAML.load_file(@persistence_filepath) || []
        else
          []
        end
      end

      # TODO: for performance we don't really have to rewrite the file every
      # time. See how fish-shell does it:
      # https://github.com/fish-shell/fish-shell/blob/92d3f5f5487ed461ff0917a4bbb4169fd0842ca8/src/history.cpp#L1557-L1564
      def save_store
        return unless @persistence_filepath
        FileUtils.mkpath(Pathname.new(@persistence_filepath).dirname.to_s)

        File.write(@persistence_filepath, store.reverse.uniq.reverse.to_yaml)
      end
    end
  end
end
