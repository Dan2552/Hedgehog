module Hedgehog
  module Execution
    class Runner
      def initialize(is_history_enabled: false)
        @is_history_enabled = is_history_enabled
      end

      def run(command_string)
        command = Hedgehog::Command.new(command_string)

        settings.input_history << command.original if is_history_enabled

        settings.execution_order.each do |adapter|
          next unless adapter.validate(command)
          return adapter.run(command)
        end
      end

      private

      attr_reader :is_history_enabled

      def settings
        Hedgehog::Settings.shared_instance
      end
    end
  end
end
