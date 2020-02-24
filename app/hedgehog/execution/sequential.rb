module Hedgehog
  module Execution
    class Sequential
      def validate(command)
        command.sequential?
      end

      def run(command)
      end
    end
  end
end
