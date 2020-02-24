module Hedgehog
  module Parse
    class CommandHandler < BaseHandler
      def handle_token
        case current_token.type
        when :end, :newline, :pipe, :right_parenthesis, :or, :and, :semicolon
          return state.pop_handler!
        when :space
          return state.consume_current_token!
        end

        log "local_state: #{local_state}"

        case local_state
        when :expecting_env_vars
          handle_expecting_env_vars
        when :expecting_arguments
          handle_expecting_arguments
        end
      end

      def build_leaves
        command = Leaf.new(:command, current_token)

        (env_var_handlers + argument_handlers).each do |handler|
          command.children << handler.build_leaves
        end

        command
      end

      private

      def handle_expecting_env_vars
        case state.peek(2)
        when [:word_starting_with_letter, :equals]
          env_var_handlers << spawn(EnvVarHandler)
        else
          log("identified as arguments")
          @local_state = :expecting_arguments
        end
      end

      def handle_expecting_arguments
        argument_handlers << spawn(ArgumentHandler)
      end

      # * expecting_env_vars: it could be env vars, but it could actually also
      #   be arguments
      # * expecting_arguments: env vars are no longer considered
      def local_state
        @local_state ||= :expecting_env_vars
      end

      def env_var_handlers
        @env_var_handlers ||= []
      end

      def argument_handlers
        @argument_handlers ||= []
      end

      def named?
        arguments.count > 0
      end
    end
  end
end
