module Hedgehog
  module Execution
    class Alias
      def validate(command)
        aliases[command.binary_name].present?
      end

      def run(command)
        aliases[command.binary_name].call(command.arguments)
      rescue LocalJumpError
        # Allow calls to `break`
      rescue Exception => e
        puts e
      end

      private

      def aliases
        Hedgehog::State.shared_instance.aliases
      end
    end
  end
end
