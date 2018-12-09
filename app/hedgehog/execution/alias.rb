module Hedgehog
  module Execution
    class Alias
      def validate(command)
        aliases[command.binary_name.to_s].present?
      end

      def run(command)
        aliases[command.binary_name.to_s].call(command.arguments)
      rescue LocalJumpError
        # Allow calls to `break`
      rescue Exception => e
        puts e
      end

      private

      def aliases
        Hedgehog::State
          .shared_instance
          .aliases
      end
    end
  end
end
