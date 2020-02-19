module Hedgehog
  module Parse
    class EnvVarHandler < BaseHandler
      def handle_token
        return handle_name unless name.present?

        handle_value
      end

      def build_leaves
        env_var = Leaf.new(:env_var, nil)
        env_var.children << Leaf.new(:lhs, name)

        if value_parts.count == 1 && value_parts.first.is_a?(Token)
          rhs = Leaf.new(:rhs, value_parts.first)
        else
          rhs = Leaf.new(:rhs, nil)
          value_parts.each do |part|
            if part.is_a?(Token)
              rhs.children << Leaf.new(:value_part, part)
            else
              rhs.children << part.build_leaves
            end
          end
        end

        env_var.children << rhs if value_parts.count > 0

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
        case current_token.type
        when :single_quote, :double_quote
          value_parts << spawn(StringHandler)
        when :dollar
          if state.peek(2).last == :left_parenthesis
            value_parts << spawn(CommandSubstitutionHandler)
          else
            value_parts << state.consume_current_token!
          end
        when :end, :space
          state.pop_handler!
        else
          value_parts << state.consume_current_token!
        end
      end

      def handle_equals
        raise_unexpected if !name.present? || equals_fulfilled

        @equals_fulfilled = true
        state.consume_current_token!
      end

      def value_parts
        @value_parts ||= []
      end
    end
  end
end
