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
        require "io/console"

        Hedgehog::Terminal.silence!
        PTY.spawn(command.with_binary_path, in: STDIN) do |stdout_and_err, stdin, pid|
          stdout_and_err.winsize = $stdout.winsize
          Signal.trap(:WINCH) do
            # puts "Terminal resized to #{$stdout.winsize}"
            stdout_and_err.winsize = $stdout.winsize
          end
          thread = Thread.new(stdin) do |terr|
            while true
              char = STDIN.read(1)
              # print(char)
              stdin << char
            end
          end
          begin
            while (char = stdout_and_err.getc)
              print char
              output += char
            end
          rescue Errno::EIO
          ensure
            thread.kill
            Process.wait(pid)
            Hedgehog::Terminal.restore!
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
