module Hedgehog
  class Command
    def <<(command)
      array = command.split(" ")
      if @command_parts
        @command_parts += ["\n"] + array
      else
        @command_parts = array
      end
    end

    def first_word
      command_parts.first
    end

    def binary_path
      path_finder.call(first_word)
    end

    def original
      command_parts.join(" ")
    end

    def with_binary_path
      full_command_parts = command_parts.dup
      full_command_parts[0] = binary_path
      full_command_parts.join(" ").gsub("\n", " ")
    end

    def arguments
      command_parts[1..-1]
    end

    def incomplete?
      last_line_has_backslash_at_end? || !balanced?
    end

    private

    attr_reader :command_parts

    def path_finder
      Hedgehog::Settings
        .shared_instance
        .binary_in_path_finder
    end

    def balanced?
      pairs = {
        '{' => '}',
        '[' => ']',
        '(' => ')',
        '`' => '`',
        "'" => "'",
        '"' => '"',
      }

      expectations = []
      original.chars do |char|
        if expectations.last == char
          expectations.pop
          next
        end

        if expectation = pairs[char]
          expectations << expectation
        end
      end

      expectations.empty?
    end

    def last_line_has_backslash_at_end?
      original.split("\n").last.match(/\\\s*$/)
    end
  end
end
