module Hedgehog
  module Execution
    class Binary
      def validate(command)
        command.binary_path.present?
      end

      def run(command)
        # To set the $? variable for the process, we first run an exit.
        #
        # e.g `$(exit 12); echo $?` will print 12
        set_previous_status = "$(exit #{$?&.exitstatus || 0}); "

        system(set_previous_status + command.with_binary_path)

      rescue Interrupt
      ensure
        Process.wait rescue SystemCallError
      end
    end
  end
end
