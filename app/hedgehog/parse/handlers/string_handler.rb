module Hedgehog
  module Parse
    class StringHandler < BaseHandler
      def handle_token
        return if determine_type

        @string_tokens = consume_tokens_until do
          current_token.type == @string_type
        end

        state.consume_current_token!
        state.pop_handler!
      end

      def build_leaves
        leaf = Leaf.new(:string, nil)

        leaf.token = @string_tokens.first if @string_tokens.count == 1

        @string_tokens.each do |token|
          leaf.children << Leaf.new(:string_part, token)
        end

        leaf
      end

      private

      def determine_type
        return false if @string_type.present?
        @string_type = current_token.type
        state.consume_current_token!
        true
      end
    end
  end
end
