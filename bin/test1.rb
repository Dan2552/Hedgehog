#!/usr/bin/env ruby
require 'pry'
# class Tee < IO
#   attr_accessor :out

#   def write(string)
#     # @fhs.each do |fh|
#     #   fh.print string
#     # end
#     super
#   end
# end

# # r, w = IO.pipe

# old_stdout = $stdout
# r, $stdout = Tee.pipe
# $stdout.out = old_stdout

# puts "Hello world"

# system("pwd")

# var = `script -q /dev/null /bin/ls -G | tee /dev/tty`
# puts "-----"
# puts var
# ""

# ./test 2> >(tee myfile.txt >&2)

class TeeIO
  def self.pipe
    new
  end
def open(*args, &block)
  binding.pry
end
# def initialize(*ios)
#   binding.pry
# end
def <<(*args)
binding.pry
end
def add(*ios)
  binding.pry
end
def <<(obj)
  binding.pry
end
def close
  binding.pry
end
def closed?
  binding.pry
end
def flush
  binding.pry
end
def print(*obj)
  binding.pry
end
def printf(format, *obj)
  binding.pry
end
def putc(char)
  binding.pry
end
def puts(*obj)
  binding.pry
end
def syswrite(string)
  binding.pry
end
def to_io
  binding.pry
end
def tty?
  binding.pry
end
def write(string)
  binding.pry
end
def write_nonblock(string)
  binding.pry
end
end


# binding.pry

to_execute = "/Users/dan2552/Dropbox/Hedgehog/bin/test_output"

io_r, io_w = IO.pipe

stdout_r, stdout_w = TeeIO.pipe
stderr_r, stderr_w = TeeIO.pipe

# stdout_r.io_r = io_r
# stdout_w.io_r = io_w
# stderr_r.io_r = io_r
# stderr_w.io_r = io_w

# stderr_thread = Thread.new do
#   should_end = false
#   c = nil
#   while true do
#     sleep 0.1
#     # semaphore.synchronize {
#     if !io_r.closed? && c = io_r.getc
#       # semaphore.synchronize do
#         # output += c
#         print c
#       # end
#       # stderr += c
#     end


#       # should_end = stderr_r.closed?
#     # }
#     # break if should_end && !c
#   end
# end
# binding.pry
# trace = TracePoint.new(:call) do |tp|
#   puts "#{tp.defined_class}##{tp.method_id} got called (#{tp.path}:#{tp.lineno})"
# end
# trace.enable

pid = spawn(to_execute, :out => stdout_w, :err => stderr_w)
# Process.wait(pid)
Process.wait
exit 1
# trace.disable
io_w.close
stdout_w.close
stderr_w.close
out = stdout_r.read
err = stderr_r.read

puts "\n--- STDOUT ---"
puts out
puts "\n--- STDERR ---"
puts err

puts "\n--- ... ---"
puts io_r.read

stdout_r.close
stderr_r.close

# binding.pry
""
