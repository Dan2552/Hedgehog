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
        system("exit #{$?&.exitstatus || 0}")

        # ----------------------
        # SYSTEM - problems: can't see output, can't print newline if there isn't one
        # system(command.with_binary_path)
        # print "\n"

        # ----------------------
        # OPEN3 - problems: no color
        # output = ""
        # require 'open3'
        # Open3.popen2e(command.with_binary_path) do |stdin, stdout_and_err, wait_thr|
        #   puts "???"
        #   while (char = stdout_and_err.getc)
        #     print char
        #     output += char
        #   end
        #   print(c)
        #   output += c
        # end

        # ----------------------
        # PTY - problems: irb doesn't work properly

        output = ""
        require 'pty'
        PTY.spawn(command.with_binary_path) do |stdout, stdin, pid|
          stdin.close
          begin
            while (char = stdout.getc)
              print char
              output += char
            end
            # stdout.each { |line| print line }
          rescue Errno::EIO
          ensure
            Process.wait(pid)
          end
        end

        print "⏎\r\n" unless output.end_with?("\r\n") || output.empty?

        Hedgehog::Execution::Ruby::Binding
          .shared_instance
          ._binding
          .local_variable_set(:_, output)
      rescue Interrupt
      ensure
        Process.wait rescue SystemCallError
      end
    end
  end
end
