module Hedgehog module Parse


    class Parser
      def initialize(tokens)
        @tokens = tokens
        @current_state = :empty
        @output = ParserOutput.new
        @current_leaf = Leaf.new(:root, nil)
      end

# :word_starting_with_letter
# :space
# :number
# :word_starting_with_number
# :equals
# :single_quote
# :double_quote
# :backtick
# :pipe

      # Parsing produces a tree.
      #
      def parse
        puts "\n\nSTART----------------"
        tokens.each do |t|
          @current_token = t
          handle_token
        end
        puts "\n\nENDED----------------"
        @output
      end

      private

      attr_reader :tokens


      attr_reader :current_state
      attr_reader :current_token
      attr_reader :current_leaf

      def handle_token
        case current_state
        when :empty
          handle_empty
        when :maybe_env_maybe_command
          handle_maybe_env_maybe_command
        end
      end

      # empty: we're looking for either:
      # - environment variables
      # - command name (binary/alias/etc) to run
      #
      def handle_empty
        case current_token
        when word_starting_with_letter
          # At this point we don't know whether this is an env var or a command
          @current_state = :maybe_env_maybe_command
        when word_starting_with_number
          # This has to be a command
        else
          raise ":( handle_empty: #{current_token}"
        end
      end

      def handle_maybe_env_maybe_command
        case current_token
        when :end
          Leaf.new(:command, current_token)
        end
      end
    end
  end
end
