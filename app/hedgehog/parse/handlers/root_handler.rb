module Hedgehog
  module Parse
    class RootHandler < BaseHandler
      def handle_token
        case current_token.type
        when :pipe, :or
          new_operator
        when :word_starting_with_letter, :word_starting_with_number, :single_quote, :double_quote
          new_command
        when :newline, :space
          state.consume_current_token!
        when :end
          state.consume_current_token!
          raise "Unconsumed tokens: #{state.tokens.map(&:type)}" unless state.finished?
        else
          raise_unexpected
        end
      end

      def build_leaves
        root = Leaf.new(:root, nil)

        elements.each do |element|
          root.children << element.build_leaves
        end

        root
      end

      protected

      def elements
        @elements ||= []
      end

      private

      def new_command
        elements << spawn(CommandHandler)
      end

      def new_operator
        # move the latest element to the lhs of the operator
        latest_element = elements.pop
        raise_unexpected unless latest_element.is_a?(CommandHandler)

        operator = spawn(OperatorHandler)
        operator.operator_token = state.consume_current_token!
        operator.lhs = latest_element
        elements << operator
      end
    end
  end
end
