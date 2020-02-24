module Hedgehog
  module Execution
    class Piped
      def validate(command)
        command.piped?
      end

      def run(command)
      end
    end
  end
end
