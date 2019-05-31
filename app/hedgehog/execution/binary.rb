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
        # PTY - problems:
        # irb doesn't work properly - SOLVED by thread passing characters into stdin
        # long outputs take forever to print
        # needs separate thread handling stdin

        # output = ""
        # require 'pty'
        # require "io/console"

        # Hedgehog::Terminal.silence!
        # PTY.spawn(to_execute) do |stdout_and_err, stdin, pid|
        #   stdout_and_err.winsize = $stdout.winsize
        #   Signal.trap(:WINCH) do
        #     stdout_and_err.winsize = $stdout.winsize
        #   end
        #   thread = Thread.new(stdin) do |terr|
        #     while true
        #       char = STDIN.read(1)
        #       stdin << char
        #     end
        #   end
        #   begin
        #     while (char = stdout_and_err.getc)
        #       print char
        #       output += char
        #     end
        #   rescue Errno::EIO
        #   ensure
        #     thread.kill
        #     Process.wait(pid)
        #     Hedgehog::Terminal.restore!
        #   end
        # end

        # -------------
        # PTY 2
        # problems:
        # - printing characters is slow (i think we're stuck with it though).

        start_time = Time.now.to_f

        output = ""
        require 'pty'
        require 'io/console'

        master, slave = PTY.open

        pid = Process.spawn(to_execute, :in => STDIN, [:out, :err] => slave)
        slave.close

        master.winsize = $stdout.winsize
        Signal.trap(:WINCH) do
          master.winsize = $stdout.winsize
        end

        Signal.trap "SIGINT" do
          Process.kill("INT", pid)
        end

        master.each_char do |char|
          STDOUT.print char
          output.concat(char)
        end

        Process.wait(pid)
        master.close

# -----------------------

        # IO.popen(to_execute, :in => STDIN, :out => slave, err: [:child, :out]) do |_|
        #   slave.close
        #   master.winsize = $stdout.winsize
        #   Signal.trap(:WINCH) do
        #     master.winsize = $stdout.winsize
        #   end

        #   master.each_char do |char|
        #     STDOUT.print char
        #     output.concat(char)
        #   end
        # end

        # puts "hello?"


# ------------------


        # Process.spawn(to_execute, out: slave, err: [:child, :out])




        print "⏎\r\n" unless output.end_with?("\r\n") || output.empty?
        puts Time.now.to_f - start_time
        Hedgehog::Execution::Ruby::Binding
          .shared_instance
          ._binding
          .local_variable_set(:_, output)
      ensure
        Process.wait rescue SystemCallError
      end
    end
  end
end
