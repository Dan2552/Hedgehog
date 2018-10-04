module Hedgehog
  module Execution
    class Runner
      def run(command_string)
        @command = @command || Hedgehog::Command.new
        @command << command_string

        return false if @command.incomplete?

        execute_command
        @command = nil

        return true
      end

      private

      def execute_command
        Hedgehog::Settings.shared_instance.execution_order.each do |adapter|
          next unless adapter.validate(@command)
          adapter.run(@command)
          return
        end
      end
    end
  end
end
