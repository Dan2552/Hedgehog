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

          system(set_previous_status + command.with_binary_path)
        end
      end
    end
  end
end
