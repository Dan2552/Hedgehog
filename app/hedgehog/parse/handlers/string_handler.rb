module Hedgehog
  module Parse
    class StringHandler < BaseHandler
      def handle_token
        return if determine_type

        @string_tokens = consume_tokens_until do
          raise_unexpected if current_token.type == :end

          result = unescaped? && current_token.type == @string_type_token.type

          @last_was_a_backslash = current_token.type == :backslash

          result
        end

        state.consume_current_token!
        state.pop_handler!
      end

      def build_leaves
        # String leaf contains the type (i.e. ' vs ")
        leaf = Leaf.new(:string, @string_type_token)

        @string_tokens.each do |token|
          leaf.children << Leaf.new(:string_part, token)
        end

        leaf
      end

      private

      def unescaped?
        @last_was_a_backslash != true
      end

      def determine_type
        return false if @string_type_token.present?
        @string_type_token = current_token
        state.consume_current_token!
        true
      end
    end
  end
end
