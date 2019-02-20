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

          to_execute = set_previous_status + command.with_binary_path



# output = ""
# errors = ""
# require 'tty-command'

# cmd = TTY::Command.new(printer: :quiet)
# cmd.run!(to_execute, pty: true, printer: :quiet) do |out, err|
#   output << out if out
#   errors << err if err
# end


require 'pty'
          stdout_r, stdout_w = PTY.open # IO.pipe
          stderr_r, stderr_w = PTY.open # IO.pipe
          # r, w = IO.pipe

          stdout_w.raw!
          stderr_w.raw!

          output = ""
          stdout = ""
          stderr = ""

          # semaphore = Mutex.new
          # process_ended = false

          # stderr_thread = Thread.new do
          #   should_end = false
          #   c = nil
          #   while true do
          #     sleep 0.1
          #     semaphore.synchronize {
          #     if !stderr_r.closed? && c = stderr_r.getc
          #       # semaphore.synchronize do
          #         output += c
          #         print c
          #       # end
          #       stderr += c
          #     end


          #       should_end = stderr_r.closed?
          #     }
          #     break if should_end && !c
          #   end
          # end

          # stdout_thread = Thread.new do
          #   should_end = false
          #   c = nil
          #   while true do
          #     sleep 0.1
          #     semaphore.synchronize {
          #     if !stdout_r.closed? && c = stdout_r.getc
          #       # semaphore.synchronize do
          #         output += c
          #         print c
          #       # end
          #       stdout += c
          #     end


          #       should_end = stdout_r.closed?
          #     }
          #     break if should_end && !c
          #   end
          # end


          pid = spawn(to_execute, :out => stdout_w, :err => stderr_w)
stdout_w.close
stderr_w.close
out = stdout_r
err = stderr_r
still_open = [out,err]  # Array that only contains the opened streams

          Thread.new do
            Process.wait
            binding.pry

            stdout_r.close
            stderr_r.close
          end


while not still_open.empty?
  fhs = select(still_open,nil,nil,nil) # wait for data available in the pipes
  # fhs[0] is an array that contains filehandlers we can read from
  if fhs[0].include? out
    begin
      printf("%s",out.readchar())
    rescue EOFError  # If we have read everything from the pipe
      # Remove out from the list of open pipes
      still_open.delete_if {|s| s==out}
    end
  end
  if fhs[0].include? err
    begin
      printf("%s",err.readchar())
    rescue EOFError  # If we have read everything from the pipe
      # Remove err from the list of open pipes
      still_open.delete_if {|s| s==err}
    end
  end
end

           #(pid)



          # semaphore.synchronize { process_ended = true }
          # stdout_thread.kill
          # stderr_thread.kill
# sleep 5
          # semaphore.synchronize {


          # }

          # stdout_thread.join
          # stderr_thread.join


          puts "\n\n-------"
          puts stdout
          puts "-------"
          puts stderr
          puts "-------"


          puts "ERR FIRST" if output == "#{stderr}#{stdout}"
          puts "OUT FIRST" if output == "#{stdout}#{stderr}"

          raise "nope" unless output == "0 1 2 3 4 5 7 11 12 14 16 17 18 20 21 22 23 24 26 28 29 30 31 32 35 36 8 9 10 13 15 19 25 27 33 34 40 42 46 51 53 54 55 56 58 61 62 63 64 65 66 67 68 69 71 74 75 76 79 80 83 84 85 89 91 92 93 94 95 96 97 6 37 38 39 41 43 44 45 47 48 49 50 52 57 59 60 70 72 73 77 78 81 82 86 87 88 90 98 99 "
        rescue Interrupt
          Process.kill("INT", pid)
          Process.wait(pid)
          puts "⏎"
        end
      end
    end
  end
end
