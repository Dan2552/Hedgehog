require 'pty'
require 'io/console'

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
        to_execute = set_previous_status + command.with_binary_path

        output = ""
        input_thread = nil
        IO.console.raw!

        PTY.spawn(to_execute) do |read, write, pid|
          write.winsize = STDOUT.winsize
          Signal.trap(:WINCH) { write.winsize = STDOUT.winsize }
          input_thread = Thread.new { IO.copy_stream(STDIN, write) }

          read.each_char do |char|
            STDOUT.print char
            output.concat(char)
          end

          ::Process.wait(pid)
        end
        input_thread.kill if input_thread

        IO.console.cooked!

        print "⏎\n" unless output.end_with?("\n") || output.empty?

        Hedgehog::Execution::Ruby::Binding
          .shared_instance
          ._binding
          .local_variable_set(:_, output)
      ensure
        ::Process.wait rescue SystemCallError
      end
    end
  end
end
