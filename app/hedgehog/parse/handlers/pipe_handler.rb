module Hedgehog
  module Parse
    class OperatorHandler < RootHandler
      def handle_token
        case current_token.type
        when :end, :newline
          state.pop_handler!
        else
          super
        end
      end

      def build_leaves
        operator = Leaf.new(@operator_token.type, @operator_token)
        operator.children << lhs = Leaf.new(:lhs, nil)
        operator.children << rhs = Leaf.new(:rhs, nil)

        lhs.children << @lhs.build_leaves

        elements.each do |element|
          rhs.children << element.build_leaves
        end

        operator
      end

      def operator_token=(operator_token)
        raise "Unexpected assignment" if @operator_token
        @operator_token = operator_token
      end

      def lhs=(lhs)
        raise "Unexpected assignment" if @lhs
        @lhs = lhs
      end
    end
  end
end
