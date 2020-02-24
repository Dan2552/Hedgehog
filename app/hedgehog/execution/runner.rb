module Hedgehog
  module Execution
    module Runner
      def self.run(command)
        command = Hedgehog::Command.new(command) if command.is_a?(String)

        Hedgehog::Settings.shared_instance.execution_order.each do |adapter|
          next unless adapter.validate(command)
          return adapter.run(command)
        end
      end
    end
  end
end
