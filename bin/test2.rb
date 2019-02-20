# require 'rubygems'
# require 'open4'

# class LoggingIO
# def initialize io, log
# @io = io
# @log = log
# end

#     def gets(sep_string=$/)
#             res = @io.gets(sep_string)
#             log res
#             res
#     end

#     def << obj
#             res = @io << obj
#             log obj
#             res
#     end

#     def log obj
#             str = obj ? obj.to_s : "(nil)\n"
#             @log << str
#     end
#     private :log
# end



# stdin = $stdin
# stdout = $stdout
# stderr = $stderr

# io_r, io_w = IO.pipe

# stdin  = LoggingIO.new($stdin, io_w)
# stdout = LoggingIO.new($stdout, io_w)
# stderr = LoggingIO.new($stderr, io_w)

# status = Open4::spawn "irb", 'stdout' => stdout, 'stderr' => stderr
# io_w.close
# # Process.wait
# puts "end"
# puts io_r.read





require "open3"

stdin, stdout, stderr = Open3.popen3('sort')
# stdin.puts "oso de peluche"
# stdin.puts "del ratón"
stdin.close
while !stdout.eof?
  puts stdout.readline
end
