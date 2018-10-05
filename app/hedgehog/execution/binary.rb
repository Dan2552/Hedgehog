module Hedgehog
  module Execution
    class Binary
      def validate(command)
        command.binary_path.present?
      end

      def run(command)
        begin
          pid = Process.spawn(command.with_binary_path)
          Process.wait
        rescue Interrupt
          Process.kill("INT", pid)
          Process.wait
          puts "⏎"
        end
      end
    end
  end
end
