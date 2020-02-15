module Hedgehog
  module Parse
    class RootHandler < BaseHandler
      def handle_token
        case current_token.type
        when :word_starting_with_letter, :word_starting_with_number
          new_command
        when :pipe
          new_pipe
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

      def new_pipe
        # move the latest command to the pipe leaf
        latest_command = elements.pop
        raise_unexpected unless latest_command.is_a?(CommandHandler)

        state.consume_current_token!
        pipe = spawn(PipeHandler)
        pipe.lhs = latest_command
        elements << pipe
      end
    end
  end
end
