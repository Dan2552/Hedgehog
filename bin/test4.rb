#!/usr/bin/env ruby

# to_execute = "/Users/dan2552/Dropbox/Hedgehog/bin/test_output"
# to_execute = "irb"
# to_execute = "ls -G"
to_execute = "/Users/dan2552/Dropbox/Hedgehog/bin/test_output 2>/dev/null"

var = `script -q /dev/null #{to_execute} | tee /dev/tty`
puts "-----"
puts var
