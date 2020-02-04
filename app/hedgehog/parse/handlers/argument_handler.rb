module Hedgehog
  module Parse
    class ArgumentHandler < BaseHandler
      def handle_token
        case current_token.type
        when :word_starting_with_letter
          @simple = current_token
          state.consume_current_token!
          state.pop_handler!
        else
          raise_unexpected
        end
      end

      def build_leaves
        Leaf.new(:argument, @simple) if @simple
      end
    end
  end
end
