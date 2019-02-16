module Hedgehog
  module Input
    # i.e. for picking a completion
    #
    class Choice
      PATH_BINARY_PROC = proc { |input|
        Hedgehog::Environment::Path
          .binaries
          .map { |path| path.split("/").last }
          .sort
          .grep(/#{input}/)
          .sort_by { |name| name.start_with?(input) ? "a_#{name}" : "b_#{name}" }
      }

      # The default proc is simply autocompleting for a filepath.
      #
      DEFAULT_PROC = proc { |input|
        if input == "~"
          ["~/"]
        elsif input == "."
          ["./"]
        elsif input.empty?
          ["./", "~/", "/"]
        else
          results = Readline::FILENAME_COMPLETION_PROC.call(input) || []
          results.map! do |result|
            directory = File.directory?(result.gsub(/^~/, "#{ENV["HOME"]}"))

            if directory && !result.end_with?("/")
              "#{result}/"
            else
              result
            end
          end.sort_by { |f| f.end_with?("/") ? "a" : "b" }
        end
      }

      def initialize(editor: nil, handle_teletype: true, completion_proc: nil)
        @editor = editor
        @handle_teletype = handle_teletype
        @results_to_show = 0
        @selected_row = 0
        @previous_draw_amount_of_lines = 0
        @spacing = 0
        @completion_proc = completion_proc || DEFAULT_PROC
      end

      # Renders an interactive list of choices.
      #
      # - parameter current_word: The word, so far, to be suggested to
      #   autocomplete. A "/" separated path is a single word.
      # - parameter spacing: How many columns along the choice should be
      #   rendered at. I.e. to align with the word that is being suggested.
      # - returns: The selection's String value.
      #
      def read_choice(current_word, spacing)
        self.current_word = current_word.delete_prefix('"').delete_suffix('"')
        self.spacing = spacing
        self.results_to_show = [suggestions.count, 8].min

        return nil if results_to_show == 0

        Terminal.hide_cursor
        Hedgehog::Terminal.silence! if handle_teletype
        draw
        loop do
          result = handle_character
          return nil if result == :cancel
          if result.is_a? String
            return "\"#{result}\"" if result.include?(" ")
            return result
          end
        end
      ensure
        Terminal.show_cursor
        Hedgehog::Terminal.restore! if handle_teletype
      end

      private

      attr_reader :editor

      # Whether teletype silencing should be managed by this class. This should
      # only be disabled if called from another input source (e.g. Editor).
      #
      attr_reader :handle_teletype

      # Number of results to show.
      #
      attr_accessor :results_to_show

      # The currently selected row (i.e. the one to be highlighted).
      #
      attr_accessor :selected_row

      # Spacing ahead of the suggestions.
      #
      attr_accessor :spacing

      def extra_spacing
        @extra_spacing || 0
      end

      # The current characters of the word that is being completed.
      #
      attr_accessor :current_word

      # The proc that is used to determine completions.
      #
      attr_accessor :completion_proc

      # The amount of lines that were drawn the last time `draw` was called.
      #
      # This is used to paint over previously rendered lines.
      #
      attr_accessor :previous_draw_amount_of_lines

      # Work out the width that the suggestions box should be shown at (minus
      # padding).
      #
      # E.g. if the longest word were "Documents", the result would be 9.
      #
      def width_of_suggestions
        longest = 1
        suggestions_to_render[0...results_to_show].each do |result|
          longest = [longest, result.length].max
        end
        longest
      end

      # Clears previous renderings and then renders the choice selection.
      #
      def draw
        clear_all

        suggestions_to_render[0...results_to_show].each.with_index do |result, index|
          render_option(result, index)
        end

        self.previous_draw_amount_of_lines = results_to_show
      end

      # Clears all lines rendered by this instance.
      #
      def clear_all
        Terminal.move_up(previous_draw_amount_of_lines)
        Terminal.clear_screen_from_cursor
      end

      # Draws a single line for the choice selection.
      #
      def render_option(result, index)
        color = index == selected_row ? 255 : 234
        bg_color = index == selected_row ? 25 : 255

        extra_padding = " " * (width_of_suggestions - result.length)
        text = " #{result}#{extra_padding} "
        target_spacing = spacing + extra_spacing

        diff = Hedgehog::Terminal.columns - (target_spacing + text.length)

        actual_spacing = target_spacing
        actual_spacing = actual_spacing + diff if diff < 0

        print("\n")
        print "\e[0G"
        print(" " * [actual_spacing, 0].max)
        print(str_with_color(text, color: color, bg_color: bg_color))
      end

      # TODO: refactor out of here
      def str_with_color(str, color: nil, bg_color: nil)
        color = "\x1b[38;5;#{color}m" if color
        bg_color = "\x1b[48;5;#{bg_color}m" if bg_color
        reset = "\x1b[0m"
        "#{color}#{bg_color}#{str}#{reset}"
      end

      def characters
        @characters ||= Hedgehog::Input::Characters.new
      end

      # Make an action based on the input character.
      #
      def handle_character
        char = characters.get_next
        return interupt if char.is?(:ctrl_c)
        return cancel if char.is?(:escape)
        return go_up if char.is?(:up)
        return go_down if char.is?(:down)
        return enter if char.is?(:enter)
        return right if char.is?(:right)
        return left if char.is?(:left)
        return right if char.is?(:option_right)
        return left if char.is?(:option_left)


        if editor
          editor.auto_complete_input = char
          cancel
        end
      end

      def interupt
        clear_all
        raise Interrupt
      end

      def left
        return unless editor
        editor.auto_complete_input = Hedgehog::Input::Characters::Character.new("\t")
        clear_all
        suggestions[selected_row].split(/(?<=[\/])/)[0..-3].join("")
      end

      def right
        return unless editor
        editor.auto_complete_input = Hedgehog::Input::Characters::Character.new("\t")
        enter
      end

      def go_up
        self.selected_row = [selected_row - 1 , 0].max
        draw
        :noop
      end

      def go_down
        self.selected_row = [selected_row + 1, previous_draw_amount_of_lines - 1].min
        draw
        :noop
      end

      def enter
        clear_all

        suggestions[selected_row]
      end

      def suggestions
        @suggestions ||= (completion_proc.call(current_word) || []).uniq
      end

      def suggestions_to_render
        @suggestions_to_render ||= begin
          suggestions.map do |suggestion|
            components = suggestion.split(/(?<=[\/])/)

            @extra_spacing ||= components[0..-2].join("").length

            components.last[0..Hedgehog::Terminal.columns - 3]
          end
        end
      end

      def cancel
        clear_all
        :cancel
      end
    end
  end
end
