module Hedgehog
  module Execution
    class Alias
      def validate(command)
        aliases[command.first_word].present?
      end

      def run(command)
        aliases[command.first_word].call(*command.arguments)
      rescue LocalJumpError
        # Allow calls to `break`
      end

      private

      def aliases
        Hedgehog::State.shared_instance.aliases
      end
    end
  end
end
