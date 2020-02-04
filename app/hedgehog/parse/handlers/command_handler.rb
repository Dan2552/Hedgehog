module Hedgehog
  module Parse
    class CommandHandler < BaseHandler
      def handle_token
        log "local_state: #{local_state}"

        case current_token.type
        when :word_starting_with_letter
            # arguments << current_token
            # state.consume_current_token!
          case local_state
          when :first
            state.skip_token!
            @local_state = :first_word
          when :first_word
            raise "Unexpected token :word_starting_with_letter"
          end
        when :end
          case local_state
          when :first_word
            state.rewind!
            arguments << current_token
            state.consume_current_token!
            @local_state = :arguments
          end
          state.pop_handler!
        else
          raise ":( command: #{current_token}"
        end
      end

      def build_leaves
        command = Leaf.new(:command, current_token)
        arguments.each do |argument|
          if argument.is_a?(Token)
            command.children << Leaf.new(:argument, argument)
          elsif argument.is_a?(BaseHandler)
            raise "TODO"
          else
            raise "Unexpected"
          end
        end
        command
      end

      private

      # * first: Expecting env vars / arguments.
      # * first_word: Still env vars / arguments. At this point, the next token
      #   will always decide which.
      # * arguments: At this point, we're done with env vars.
      #
      def local_state
        @local_state ||= :first
      end

      def env_vars
        @env_vars ||= {}
      end

      def arguments
        @arguments ||= []
      end

      def named?
        arguments.count > 0
      end
    end
  end
end
