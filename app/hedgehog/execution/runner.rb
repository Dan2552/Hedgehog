module Hedgehog
  module Execution
    class Runner
      def run(command_string)
        command = Hedgehog::Command.new(command_string)

        settings.execution_order.each do |adapter|
          next unless adapter.validate(command)
          return adapter.run(command)
        end
      end

      private

      def settings
        Hedgehog::Settings.shared_instance
      end
    end
  end
end
