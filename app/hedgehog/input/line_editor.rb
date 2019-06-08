module Hedgehog
  module Input
    # - Prints prompt
    # - Prints line
    # - Manipulates line with user input
    # - Prints autosuggestions
    #
    class LineEditor
      # Choice instance sets this when a character that the editor should handle
      # is typed.
      #
      attr_accessor :auto_complete_input

      def initialize(handle_teletype: true)
        @handle_teletype = handle_teletype
      end

      # Similarly to the readline library, the aim is to get a line of text.
      #
      # - returns: String, being the line
      #
      def readline(prompt)
        Signal.trap('SIGWINCH', method(:size_changed))
        Hedgehog::Terminal.silence! if handle_teletype
        @prompt = prompt
        redraw
        loop do
          result = handle_character
          return nil if result == :cancel
          if result == :finish
            line.cursor_index = line.visible_length
            redraw(without_suffix: true)
            Hedgehog::Terminal.restore!
            puts ""
            return visible_text
          end
        end
      ensure
        Hedgehog::Terminal.restore! if handle_teletype
        @line = nil
        @last_cursor_rows = nil
        reset_history_state
      end

      private

      def size_changed(_)
        return if @line.nil?

        @line.terminal_did_resize(
          Hedgehog::Terminal.columns,
          Hedgehog::Terminal.rows
        )
        redraw
      end

      # Whether teletype silencing should be managed by this class. This should
      # only be disabled if called from another input source (e.g. Editor).
      #
      attr_reader :handle_teletype

      attr_reader :prompt

      def colored_suffix
        return unless line.suffix.present?
        Hedgehog::StringExtensions.with_color(line.suffix, color: 240)
      end

      def size(str)
        Hedgehog::StringExtensions.without_color(str).length
      end

      def characters
        @characters ||= Hedgehog::Input::Characters.new
      end

      def line
        @line ||= TerminalLine.new(
          cols: Terminal.columns,
          rows: Terminal.rows,
          text: "",
          cursor_index: 0,
          prefix: prompt,
          suffix: nil
        )
      end

      def redraw(without_suffix: false)
        Terminal.title = Dir.pwd.split("/").last

        Terminal.hide_cursor

        Terminal.move_up(@last_cursor_rows || 0)
        Terminal.move_to_start_of_line # prevents jumping when line wrapping
        Terminal.clear_screen_from_cursor

        print(prompt)
        prompt_length = StringExtensions.without_color(prompt).length

        text_to_render = line.text.gsub("\n", "\n\e[0G")

        if @history_matching.present?
          text_to_render.sub!(
            @history_matching,
            Hedgehog::StringExtensions.with_color(
              @history_matching,
              color: 0,
              bg_color: 15
            )
          )
        end

        print(text_to_render)

        if line.suffix.present? && !without_suffix
          print(colored_suffix.gsub("\n", "\n\e[0G"))
        end

        # A little workaround because printing *exactly* the width of the
        # terminal the would result in the cursor overlapping with the last
        # character, which behaves differently to where we actually want the
        # cursor. This forces the cursor over to the next character space where
        # it should be.
        #
        # This fix doesn't fit in TerminalLine because we *do* want cursor_rows
        # or max_cursor_rows to be on the next line.
        print(" ") and Terminal.move_left and Terminal.clear_screen_from_cursor

        Terminal.move_up(line.max_cursor_rows)
        Terminal.move_down(line.cursor_rows)
        Terminal.move_to_start_of_line
        Terminal.move_right(line.cursor_cols)

        Terminal.show_cursor

        @last_cursor_rows = line.cursor_rows
      end

      # Make an action based on the input character
      #
      # - Move the cursor
      # - Input a character
      # - Delete a character
      #
      # - returns: true if \n, otherwise false
      def handle_character(overriden_char = nil)
        return handle_character_for_auto_complete if auto_complete_input
        char = overriden_char || characters.get_next

        return up if char.is?(:up)
        return down if char.is?(:down)

        # Anything other than up or down should reset the history navigation.
        reset_history_state

        return go_left if char.is?(:left)
        return go_right if char.is?(:right)
        return go_left_by_word if char.is?(:option_left)
        return go_right_by_word if char.is?(:option_right)
        return :cancel if char.is?(:ctrl_d)
        return interrupt if char.is?(:ctrl_c)
        return backspace if char.is?(:backspace)
        return delete if char.is?(:delete)
        return enter if char.is?(:enter)
        return auto_complete if char.is?(:tab)

        return if char.unknown? || char.known_special?

        line.insert(line.cursor_index, char)
        line.cursor_index = line.cursor_index + 1
        auto_suggest
        redraw
      end

      def handle_character_for_auto_complete
        char = auto_complete_input
        self.auto_complete_input = nil
        handle_character(char) unless char.is?(:tab)
        redraw
        auto_complete
      end

      def enter
        return :finish unless Hedgehog::Command.new(visible_text).incomplete?
        line.insert(line.cursor_index, "\n")
        line.cursor_index = line.cursor_index + 1
        redraw
      end

      def go_left
        return if line.cursor_index - 1 < 0
        line.cursor_index = line.cursor_index - 1
        redraw
      end

      def go_right
        if line.cursor_index > line.visible_length - 1
          return accept_auto_suggestion
        end

        line.cursor_index = line.cursor_index + 1
        redraw
      end

      def go_left_by_word
        if line[line.cursor_index - 1] == " "
          go_left
        end
        _, range, _ = current_word_and_range_and_index
        line.cursor_index = range.first
        redraw
      end

      def go_right_by_word
        go_right if line.cursor_index == 0
        go_right if line[line.cursor_index] == " "
        go_right if line[line.cursor_index - 1] == " "

        _, range, _ = current_word_and_range_and_index
        line.cursor_index = range.last + 1
        redraw
      end

      def backspace
        return if line.cursor_index == 0

        line[line.cursor_index - 1] = ''
        auto_suggest
        go_left
      end

      def delete
        return if line.cursor_index == line.visible_length - 1
        line[line.cursor_index] = ''
        auto_suggest
        redraw
      end

      def interrupt
        unless line.text.present?
          redraw(without_suffix: true)
          return
        end

        line.cursor_index = line.visible_length
        redraw(without_suffix: true)
        print(Hedgehog::StringExtensions.with_color("^C", color: 0, bg_color: 15))
        raise Interrupt
      end

      def auto_complete
        complete_proc = if line.text.include?(" ")
                          Hedgehog::Input::Choice::BASH_AND_FILEPATHS_PROC
                        else
                          Hedgehog::Input::Choice::PATH_BINARY_AND_FILEPATHS_PROC
                        end

        current_word, range, word_index = current_word_and_range_and_index

        indentation = [size(prompt) + range.first - 1, 0].max

        # COMP_WORDS and COMP_CWORD are used by bash-style autocompletion.
        #
        ENV["COMP_WORDS"] = "(" + words.map { |w| "'#{w}'" }.join(" ") + ")"
        ENV["COMP_CWORD"] = word_index.to_s
        ENV["COMP_LINE"] = line.text
        ENV["COMP_POINT"] = line.cursor_index.to_s

        result = Hedgehog::Input::Choice
          .new(editor: self, handle_teletype: false, completion_proc: complete_proc)
          .read_choice(current_word, indentation)

        ENV["COMP_WORDS"] = nil
        ENV["COMP_CWORD"] = nil
        ENV["COMP_LINE"] = nil
        ENV["COMP_POINT"] = nil

        if result
          line[range] = result
          line.cursor_index = range.first + result.length
        else
          line.cursor_index = size(line.text)
        end

        auto_suggest
        redraw
      rescue Interrupt
        interrupt
      end

      def words
        words = line.text.split(Hedgehog::Command::UNESCAPED_WORD_REGEX)
        words << "" if line.text.end_with?(" ")
        words
      end

      # The word that the cursor is on and the character it starts on.
      #
      # For example
      #   01234567890
      #   hello world
      #          ^
      # would return ["world", 6..10]
      #
      def current_word_and_range_and_index
        iterated_chars = 0
        this_is_the_word = false
        words.each.with_index do |word, index|
          word_started_on = iterated_chars
          word.each_char do |char|
            this_is_the_word = true if iterated_chars == line.cursor_index - 1
            iterated_chars = iterated_chars + 1
          end
          word_ended_on = iterated_chars - 1
          return [word, word_started_on..word_ended_on, index] if this_is_the_word

          # For the space character
          iterated_chars = iterated_chars + 1
        end
        return ["", line.cursor_index..line.cursor_index, words.count]
      end

      # TODO: spec
      def up
        # TODO logic for navigating multiple lines and `if line.cursor_index == line.visible_length`
        # TODO when doing anything not history navigation, history should be reset
        return nav_through_history(:up)
      end

      # TODO: spec
      def down
        # TODO logic for navigating multiple lines and `if line.cursor_index == line.visible_length`
        # TODO when doing anything not history navigation, history should be reset
        return nav_through_history(:down)
      end

      # TODO: spec
      def nav_through_history(direction)
        @history_matching ||= line.text

        result = if direction == :up
                   input_history.up(matching: @history_matching)
                 elsif direction == :down
                   input_history.down(matching: @history_matching)
                 end

        if result == nil && direction == :down
          line.text = @history_matching
          @history_matching = nil
        elsif result == nil
          return
        else
          line.text = result
        end

        line.cursor_index = line.visible_length
        auto_suggest
        redraw
      end

      def input_history
        Hedgehog::Settings.shared_instance.input_history
      end

      def reset_history_state
        @history_matching = nil
        input_history.reset_index!
      end

      def visible_text
        Hedgehog::StringExtensions.without_color(line.text)
      end

      def auto_suggest
        return line.suffix = nil unless line.text.present?
        suggestion = input_history.suggestion_for(line.text)
        return line.suffix = nil unless suggestion.present?

        line.suffix = suggestion.sub(line.text, "").rstrip.presence
      end

      def accept_auto_suggestion
        line.text = line.text + line.suffix
        auto_suggest
        redraw
      end
    end
  end
end
