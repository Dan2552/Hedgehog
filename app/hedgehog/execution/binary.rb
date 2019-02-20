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

          # Allow recording of session characters. Allowing both color
          # characters and interactive sessions to be recorded.
          make_typescript_of_terminal_session = "script -q /dev/null "

          # Pipe to terminal while we're taking the original stdout/stderr
          # output into our io_pipe object.
          pipe_to_terminal = " | tee /dev/tty"

          to_execute = set_previous_status +
            make_typescript_of_terminal_session +
            command.with_binary_path +
            pipe_to_terminal

          io_r, io_w = IO.pipe
          pid = Process.spawn(to_execute, out: io_w)
          io_w.close
          Process.wait

          $output = io_r.read

          io_r.close
        rescue Interrupt
          Process.kill("INT", pid)
          Process.wait(pid)
          puts "⏎"
        end
      end
    end
  end
end
