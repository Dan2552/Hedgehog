module Hedgehog
  module Parse
    class EnvVarHandler < BaseHandler
      def handle_token
        case current_token.type
        when :word_starting_with_letter # TODO: , :word_starting_with_number, etc
          return handle_name unless name.present?
          return handle_value if equals_fulfilled
          raise_unexpected
        when :equals
          return handle_equals
        # when :end # TODO: spec
        #   state.pop_handler!
        else
          raise_unexpected
        end
      end

      def build_leaves
        env_var = Leaf.new(:env_var, nil)
        env_var.children << Leaf.new(:lhs, name)
        env_var.children << Leaf.new(:rhs, value) if value.present?
        env_var
      end

      private

      attr_reader :name
      attr_reader :value
      attr_reader :equals_fulfilled

      def handle_name
        @name = current_token
        state.consume_current_token!
      end

      def handle_value
        @value = current_token
        state.consume_current_token!
        state.pop_handler!
      end

      def handle_equals
        raise_unexpected if !name.present? || equals_fulfilled

        @equals_fulfilled = true
        state.consume_current_token!
      end
    end
  end
end
