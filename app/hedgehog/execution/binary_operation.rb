module Hedgehog
  module Execution
    class BinaryOperation
      def validate(command)
        command.binary_operation?
      end

      def run(command)
        parts = command.operation_parts

        Runner.run(parts[:lhs])

        success = $? == 0

        if parts[:operator] == :and
          Runner.run(parts[:rhs]) if success
        elsif parts[:operator]  == :or
          Runner.run(parts[:rhs]) unless success
        end
      end
    end
  end
end
