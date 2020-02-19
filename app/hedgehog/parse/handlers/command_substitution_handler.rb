module Hedgehog
  module Parse
    class CommandSubstitutionHandler < RootHandler
      def handle_token
        return if determine_type
        return if closing

        super
      end

      def build_leaves
        leaf = Leaf.new(:command_substitution, @type_token)
        leaf.children << super
        leaf
      end

      private

      def determine_type
        return false if @type_token.present?
        @type_token = state.consume_current_token!

        # consume ( if it's a $() style substitution
        state.consume_current_token! if @type_token.type == :dollar

        true
      end

      def closing
        if @type_token.type == :dollar && current_token.type == :right_parenthesis
          state.consume_current_token!
          state.pop_handler!
          true
        elsif @type_token.type == :backtick
          true
        else
          false
        end
      end
    end
  end
end
