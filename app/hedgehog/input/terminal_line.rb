module Hedgehog
  module Input
    # Keeps track of a "line" of text (which can actually be multi-line) within
    # the space of a terminal window for:
    # - Calculating what needs redrawing (in terms of changes for rendering)
    # - Calculating cursor position (x, y)
    #
    class TerminalLine
      # - parameter cols: The amount of columns the terminal presently has
      # - parameter rows: The amount of rows the terminal presently has
      # - parameter text: The text (can include invisible charactesr, e.g. color
      #   characters)
      # - parameter cursor_index: The index of where the cursor should be in
      #   terms of visible characters in the text
      # - parameter prefix: If the line we care about has a prefix that doesn't
      #   count as part of the "line" but will still take up space
      #
      def initialize(cols:, rows:, text:, cursor_index:, prefix:, suffix:)
        @cols = cols.to_i
        @rows = rows.to_i
        @text = text.to_s.dup
        @cursor_index = cursor_index.to_i
        @prefix = prefix.to_s.dup
        @suffix = suffix.to_s.dup

        calculate_cursor_position
      end

      # The amount of columns the terminal has
      #
      attr_reader :cols

      # The amount of rows the terminal has
      #
      attr_reader :rows

      # The row of the cursor in the terminal considering the size of the window
      # and whether the prefix is taking up space.
      #
      def cursor_rows
        @cursor_rows
      end

      # The columns of the cursor in the terminal considering the size of the
      # window and whether the prefix is taking up space.
      #
      def cursor_cols
        @cursor_cols
      end

      # The maximum number of rows that the prefix and text should take up.
      #
      def max_cursor_rows
        @max_cursor_rows
      end

      # The maximum number of columns on the last maximum row that the prefix
      # and text should take up.
      #
      def max_cursor_cols
        @max_cursor_cols
      end

      # The index of where the cursor should be in terms of visible characters
      # in the text.
      #
      def cursor_index
        @cursor_index
      end

      # Move the cursor to a specific index in the text.
      #
      def cursor_index=(new_value)
        @cursor_index = new_value.to_i

        calculate_cursor_position
      end

      # The text (including invisible characters e.g. color characters).
      #
      def text
        @text
      end

      # Sets the text
      #
      # To avoid ambiguity, this will set the cursor_index to end of visible
      # text.
      #
      def text=(new_value)
        @text = new_value.dup
        @cursor_index = visible_length

        calculate_cursor_position
      end

      # This should be called when the terminal is resized.
      #
      # Resizing the terminal can result in the cursor being in a different
      # position to previously - this method will update the known position.
      #
      # - parameter cols: Updated amount of columns
      # - parameter rows: Updated amount of rows
      #
      def terminal_did_resize(cols, rows)
        @cols = cols
        @rows = rows

        calculate_cursor_position
      end

      # A list of indexes that need redrawing.
      #
      # (including invisible characters e.g. color characters).
      #
      def dirty_indexes
        @dirty_indexes ||= []
      end

      # Insert character(s) at a certain position of the text (position
      # including invisible characters e.g. color characters).
      #
      def insert(index, value)
        result = @text.insert(index, value)
        (index...text.length).to_a.each { |n| self.dirty_indexes << n }
        result
      end

      # Get a given character, or range of characters, in the text.
      #
      def [](index_or_range)
        @text[index_or_range]
      end

      # Replace a given character, or range of characters, in the text.
      # (position including invisible characters e.g. color characters).
      #
      def []=(index_or_range, value)
        old_length = text.length
        result = (@text[index_or_range] = value)

        first = if index_or_range.is_a?(Range)
                  index_or_range.first
                else
                  index_or_range
                end

        if old_length == text.length && value.length == 1
          self.dirty_indexes << first
        else
          (first...text.length).to_a.each { |n| self.dirty_indexes << n }
        end

        result
      end

      # The length of the text without invisible characters (e.g. without
      # color characters)
      #
      # The highest value is the maximum cursor position.
      #
      def visible_length
        visible_length_of(@text)
      end

      private

      def calculate_cursor_position
        counted_rows = 0
        counted_cols = 0
        visible_text = Hedgehog::StringExtensions.without_color(@prefix) +
                       Hedgehog::StringExtensions.without_color(@text) +
                       Hedgehog::StringExtensions.without_color(@suffix)

        @cursor_rows = nil
        @cursor_cols = nil

        target_index = visible_prefix_length + cursor_index

        # The extra space serves to allow counting up to past the last character
        (visible_text + " ").each_char.with_index do |char, index|
          # puts "#{char}: #{index} == #{target_index}"

          if index == target_index
            @cursor_rows = counted_rows
            @cursor_cols = counted_cols
          end

          if index == visible_text.length
            @max_cursor_rows = counted_rows
            @max_cursor_cols = counted_cols
          end

          if char == "\n"
            counted_rows = counted_rows + 1
            counted_cols = 0
          else
            if counted_cols == cols - 1
              counted_rows = counted_rows + 1
              counted_cols = 0
            else
              counted_cols = counted_cols + 1
            end
          end
        end
      end

      def visible_prefix_length
        @prefix.present? ? visible_length_of(@prefix) : 0
      end

      def visible_length_of(str)
        return 0 unless str

        Hedgehog::StringExtensions.without_color(str).length
      end
    end
  end
end


