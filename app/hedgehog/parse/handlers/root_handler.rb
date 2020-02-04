module Hedgehog
  module Parse
    class RootHandler < BaseHandler
      def initialize(*args)
        super
        @unknown_command_or_env = true
      end

      # States:
      # * Expecting env vars
      # * Command
      def handle_token
        case current_token.type
        when :word_starting_with_letter # TODO: :word_starting_with_number
          new_command
        when :end
          state.consume_current_token!
          raise "Unconsumed tokens: #{state.tokens.map(&:type)}" unless state.tokens.count == 0
        else
          raise ":( handle RootHandler: #{current_token}"
        end
      end

      def build_leaves
        root = Leaf.new(:root, nil)

        commands.each do |command|
          root.children << command.build_leaves
        end

        root
      end

      private

      def new_command
        commands << spawn(CommandHandler)
      end

      # Each command will be a command separated by pipe.
      #
      def commands
        @commands ||= []
      end
    end
  end
end
