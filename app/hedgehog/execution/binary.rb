module Hedgehog
  module Execution
    class Binary
      def validate(command)
        command.binary_path.present?
      end

      def run(command)
        Process.spawn(command.with_binary_path)
        Process.wait
      end
    end
  end
end
