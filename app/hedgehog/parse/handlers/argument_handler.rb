module Hedgehog
  module Parse
    class ArgumentHandler < BaseHandler
      def handle_token
        case current_token.type
        when :space, :end
          state.pop_handler!
        else
          @argument_tokens = consume_tokens_until_space_or_end
          log("consumed #{@argument_tokens.count} tokens")
        end
      end

      def build_leaves
        if @argument_tokens.count == 1
          Leaf.new(:argument, @argument_tokens.first)
        else
          args = Leaf.new(:argument, nil)
          @argument_tokens.each do |token|
            args.children << Leaf.new(:argument_part, token)
          end
          args
        end
      end

      private

      def consume_tokens_until_space_or_end(tokens = [])
        return tokens if current_token.type == :space || current_token.type == :end
        log("consuming #{current_token}")
        tokens << state.consume_current_token!
        consume_tokens_until_space_or_end(tokens)
      end
    end
  end
end
