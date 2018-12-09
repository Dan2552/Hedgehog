module Hedgehog
  module Execution
    class Runner
      def initialize(history: false)
        @history = history
      end

      def run(command_string)
        @command = @command || Hedgehog::Command.new
        @command << command_string

        return false if @command.incomplete?

        execute_command
        @command = nil

        return true
      end

      private

      attr_reader :history

      def execute_command
        # TODO: spec
        settings.input_history << @command.original if history

        settings.execution_order.each do |adapter|
          next unless adapter.validate(@command)
          adapter.run(@command)
          return
        end
      end

      def settings
        Hedgehog::Settings.shared_instance
      end
    end
  end
end
