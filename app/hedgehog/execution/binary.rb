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
        require 'pty'
        require 'io/console'

        master, slave = PTY.open

        pid = ::Process.spawn(to_execute, :in => STDIN, [:out, :err] => slave)
        slave.close
        master.winsize = $stdout.winsize
        Signal.trap(:WINCH) { master.winsize = $stdout.winsize }
        Signal.trap(:SIGINT) { ::Process.kill("INT", pid) }

        master.each_char do |char|
          STDOUT.print char
          output.concat(char)
        end

        ::Process.wait(pid)
        master.close

        print "⏎\r\n" unless output.end_with?("\r\n") || output.empty?

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
