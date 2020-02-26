module Hedgehog
  module Parse
    class State
      attr_reader :tokens

      def initialize(tokens, root)
        raise "Expected :end at the end of the token list" unless tokens.last.type == :end
        @tokens = tokens
        self.current_handler = root.new(self, 0)
        rewind!
      end

      def to_s
        "<State>"
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

      # Peek at the upcoming tokens (taking into acconut the current_token's
      # position).
      #
      # - returns: An array of types (symbols)
      #
      def peek(count)
        tokens[current_index..(current_index + (count - 1))].map(&:type)
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
