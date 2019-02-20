#!/usr/bin/env ruby

require 'pty'
require 'io/console'

semaphore = Mutex.new

to_execute = "/Users/dan2552/Dropbox/Hedgehog/bin/test_output"

stdout_r, stdout_w = PTY.open
stderr_r, stderr_w = PTY.open

stdout_w.raw!
stderr_w.raw!

output = ""
stdout = ""
stderr = ""

stdout_r.sync = true
stderr_r.sync = true
stdout_w.sync = true
stderr_w.sync = true

finished = false

stderr_thread = Thread.new do
  should_end = false
  c = nil
  while true do
    if c = stderr_r.getc
      semaphore.synchronize do
        output += c
        print c
        stderr += c
      end
    end
    semaphore.synchronize { should_end = finished }

    break if should_end && !c
  end
end

stdout_thread = Thread.new do
  should_end = false
  c = nil
  while true do
    if c = stdout_r.getc
      semaphore.synchronize do
        output += c
        print c
        stdout += c
      end
    end
    semaphore.synchronize { should_end = finished }

    break if should_end && !c
  end
end

spawn(to_execute, :out => stdout_w, :err => stderr_w)
Process.wait

stdout_w.close
stderr_w.close
semaphore.synchronize { finished = true }
stdout_thread.join
stderr_thread.join
stdout_r.close
stderr_r.close

puts "\n--- STDOUT ---"
puts stdout
puts "\n--- STDERR ---"
puts stderr
puts "\n--- BOTH ---"
puts output
