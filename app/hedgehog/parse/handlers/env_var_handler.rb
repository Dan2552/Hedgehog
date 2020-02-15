module Hedgehog
  module Parse
    class EnvVarHandler < BaseHandler
      def handle_token
        return handle_name unless name.present?

        handle_value
        state.pop_handler!
      end

      def build_leaves
        env_var = Leaf.new(:env_var, nil)
        env_var.children << Leaf.new(:lhs, name)

        if @value_tokens.count == 1
          rhs = Leaf.new(:rhs, @value_tokens.first)
        else
          rhs = Leaf.new(:rhs, nil)
          @value_tokens.each do |token|
            rhs.children << Leaf.new(:rhs_part, token)
          end
        end

        env_var.children << rhs if @value_tokens.count > 0

        env_var
      end

      private

      attr_reader :name
      attr_reader :value
      attr_reader :equals_fulfilled

      def handle_name
        case current_token.type
        when :word_starting_with_letter
          @name = current_token
          state.consume_current_token!

          raise_unexpected unless current_token.type == :equals
          state.consume_current_token!
        else
          raise_unexpected
        end
      end

      def handle_value
        @value_tokens = consume_tokens_until do
          current_token.type == :end || current_token.type == :space
        end
      end

      def handle_equals
        raise_unexpected if !name.present? || equals_fulfilled

        @equals_fulfilled = true
        state.consume_current_token!
      end
    end
  end
end
