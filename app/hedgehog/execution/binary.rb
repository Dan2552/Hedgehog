module Hedgehog
  module Execution
    class Binary
      def validate(command)
        command.binary_path.present?
      end

      def run(command)
        begin
          # To set the $? variable for the process, we first run an exit.
          #
          # e.g `$(exit 12); echo $?` will print 12
          set_previous_status = "$(exit #{$?&.exitstatus || 0}); "

          pid = Process.spawn(set_previous_status + command.with_binary_path)
          Process.wait(pid)
        rescue Interrupt
          Process.kill("INT", pid)
          Process.wait(pid)
          puts "⏎"
        end
      end
    end
  end
end
