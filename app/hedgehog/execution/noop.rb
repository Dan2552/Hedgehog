module Hedgehog
  module Execution
    class Noop
      def validate(command)
        command.original == ""
      end

      def run(command)
      end
    end
  end
end
