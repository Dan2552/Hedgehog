module Hedgehog
  module Parse
    class Token
      def initialize(type, text)
        @type = type
        @text = text
      end

      attr_reader :type
      attr_reader :text

      def to_s
        "<Token:#{type}:#{text.to_s.sub("\n", "")}>"
      end
    end

    # Converts a text into a list of tokens for parsing.
    #
    class Tokens
      def initialize(text)
        @text = text.strip
        @tokens = []
        @current_state = :empty
        @current_word = ""
      end

      def tokenize
        log "\n\nSTART----------------"
        text.each_char do |c|
          @current_char = c
          handle_char
        end
        handle_end
        log "ENDED----------------\n\n"
        @tokens
      end

      private

      attr_reader :text
      attr_reader :current_word
      attr_reader :current_state
      attr_reader :current_char

      def inspect
        tokens = @tokens.map(&:type).map(&:to_s).join(",")
        "[#{tokens}]"
      end

      def handle_char
        log "\ncharacter #{current_char}"
        case current_state
        when :empty
          handle_empty
        when :word_starting_with_letter, :word_starting_with_number
          handle_word
        when :number
          handle_number
        else
          raise ":( handle_char: #{current_state}"
        end
        @current_word += current_char
      end

      def handle_end
        log "  handling end"

        add_token(current_state, current_word) if current_state != :empty
        add_token(:end, "")
      end

      SINGLE_CHAR_TOKENS = {
        " " => :space,
        "=" => :equals,
        "'" => :single_quote,
        "`" => :backtick,
        "\"" => :double_quote,
        "|" => :pipe,
        "\n" => :newline,
        ";" => :semicolon, # TODO: spec
        # "~" => :tilde, # TODO: spec  not convinced
        "\\" => :backslash, # TODO: spec
        "." => :dot, # TODO: spec
        "$" => :dollar, # TODO: spec
        "(" => :left_parenthesis, # TODO: spec
        ")" => :right_parenthesis, # TODO: spec
      }

      def handle_empty
        log "  handling empty"

        @current_word = ""

        case current_char
        when /[a-zA-Z]/
          @current_state = :word_starting_with_letter
        when /\d/
          @current_state = :number
        when *SINGLE_CHAR_TOKENS.keys
          add_token(SINGLE_CHAR_TOKENS[current_char], current_char)
        else
          # TODO: spec
          @current_state = :word_starting_with_letter
          # raise ":( handle_empty: #{current_char}"
        end
      end

      def handle_word
        log "  handling word"
        case current_char
        when *SINGLE_CHAR_TOKENS.keys
          end_word
        when /[a-zA-Z]/
        when /\d/
        else
          # TODO: spec
          #raise ":( handle_word: #{current_char}"
        end
      end

      def handle_number
        log "  handling number"
        case current_char
        when /\d/
        when /[a-zA-Z]/
          @current_state = :word_starting_with_number
        else
          @current_state = :word_starting_with_number
          # TODO: spec
          # raise ":( handle_number: #{current_char}"
        end
      end

      def end_word
        add_token(current_state, current_word)

        @current_state = :empty

        handle_empty
      end

      def add_token(type, word)
        log "    + adding token #{type} (#{word})"
        @tokens << Token.new(type, word)
      end

      LOGGING = false
      def log(str)
        return unless LOGGING == true
        puts str
      end
    end
  end
end
