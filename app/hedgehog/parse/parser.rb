require_relative 'handlers/base_handler'
require_relative 'handlers/root_handler'
require_relative 'handlers/command_handler'
require_relative 'handlers/env_var_handler'

module Hedgehog
  module Parse
    class Parser
      def initialize(tokens)
        @state = State.new(tokens)
      end

      def parse
        puts "\n\nSTART----------------"
        loop do
          break if state.finished?
          @state.current_handler.next
        end
        puts "ENDED----------------\n\n"
        @state.current_handler.build_leaves
      end

      private

      attr_reader :state
    end
  end
end
