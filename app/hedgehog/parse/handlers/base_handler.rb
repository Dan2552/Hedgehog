module Hedgehog
  module Parse
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
        log("", "")
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

      def log(str, prefix = "* ")
        puts(("    " * depth) + prefix + str)
      end

      def raise_unexpected
        raise "Unexpected token #{current_token}"
      end
    end
  end
end
