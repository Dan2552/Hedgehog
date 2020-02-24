module Hedgehog
  module Execution
    class Sequential
      def validate(command)
        command.sequential?
      end

      def run(commands)
        commands.sequence.each do |command|
          Runner.run(command)
        end
      end
    end
  end
end
