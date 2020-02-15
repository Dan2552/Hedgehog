module Hedgehog
  module Parse
    class PipeHandler < RootHandler
      def handle_token
        case current_token.type
        when :end, :newline
          state.pop_handler!
        else
          super
        end
      end

      def build_leaves
        pipe = Leaf.new(:pipe, nil)
        pipe.children << lhs = Leaf.new(:lhs, nil)
        pipe.children << rhs = Leaf.new(:rhs, nil)

        lhs.children << @lhs.build_leaves

        elements.each do |element|
          rhs.children << element.build_leaves
        end

        pipe
      end

      def lhs=(lhs)
        raise "Unexpected assignment" if @lhs
        @lhs = lhs
      end
    end
  end
end
