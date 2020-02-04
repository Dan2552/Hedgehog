module Hedgehog
  module Parse
    class State
      attr_reader :tokens

      def initialize(tokens)
        @tokens = tokens
        self.current_handler = RootHandler.new(self, 0)
        rewind!
      end

      def consume_current_token!
        tokens.delete_at(current_index)
      end

      def skip_token!
        @current_index =+ 1
      end

      def rewind!
        @current_index = 0
      end

      def finished?
        tokens.count == 0
      end

      def current_token
        tokens[current_index]
      end

      def current_handler
        handler_stack.last
      end

      def current_handler=(handler)
        handler_stack << handler
      end

      def pop_handler!
        handler_stack.pop
      end

      private

      def handler_stack
        @handlers ||= []
      end

      def current_index
        @current_index ||= 0
      end
    end
  end
end
