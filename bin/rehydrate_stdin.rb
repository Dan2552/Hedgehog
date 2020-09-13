#!/usr/bin/env ruby

begin
  require 'io/console'

  def get_char
    begin
      system("stty raw -echo")
      str = STDIN.getc
    ensure
      IO.console.cooked!
    end
    str.chr
  end

  collection = []

  require 'timeout'
  begin
    Timeout.timeout(0.1) { loop { collection << get_char } }
  rescue Timeout::Error
  end

  print "\\[hedge" if collection.count > 0
  collection.each do |char|
    print(char)
  end
ensure
  exit(ARGV[0].to_i)
end
