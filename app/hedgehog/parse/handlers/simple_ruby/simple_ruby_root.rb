module Hedgehog
  module Parse
    # The goal here is not to parse Ruby, but simply to check for unmatched
    # quotes and brackets, so that multiline input works to some degree.
    #
    class SimpleRubyRootHandler < BaseHandler
      def handle_token
        case current_token.type
        when :single_quote, :double_quote
          spawn(StringHandler)
        when :end
          state.consume_current_token!
        else
          state.consume_current_token!
        end
      end

      def build_leaves
        # TODO: the one thing we do want to build leaves for is for a sequential
        # list (i.e. split by ;) of commands
      end
    end
  end
end
