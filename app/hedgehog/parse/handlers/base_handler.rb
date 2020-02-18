module Hedgehog
  module Parse
    class UnexpectedToken < StandardError; end
    class BaseHandler
      attr_reader :state

      def initialize(state, depth)
        @depth = depth
        @state = state
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
      def handle_token
        raise "Unimplemented"
      end

      def next
        log("#{state.current_handler.class.to_s.demodulize}: #{state.current_token}", "")
        handle_token
      end

      def current_token
        state.current_token
      end

      protected

      attr_reader :depth
      attr_reader :state

      def spawn(type)
        new_handler = type.new(state, depth + 1)
        state.current_handler = new_handler
      end

      LOGGING = false
      def log(str, prefix = "* ")
        return unless LOGGING == true
        puts(("    " * depth) + prefix + str)
      end

      def raise_unexpected
        raise UnexpectedToken, "Unexpected token #{current_token}"
      end

      def consume_tokens_until(tokens = [], &blk)
        return tokens if blk.call == true
        log("consuming #{current_token}")
        tokens << state.consume_current_token!
        consume_tokens_until(tokens, &blk)
      end
    end
  end
end
