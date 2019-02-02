module Hedgehog
  module Terminal
    def columns
      ENV['COLUMNS']&.to_i || IO.console.winsize[1] || 80
    end
    module_function :columns

    def rows
      ENV['LINES']&.to_i || IO.console.winsize[0] || 24
    end
    module_function :rows

    def hide_cursor
      print "\e[?25l"
    end
    module_function :hide_cursor

    def show_cursor
      print "\e[?25h"
    end
    module_function :show_cursor

    def clear_screen_from_cursor
      print "\e[0J"
    end
    module_function :clear_screen_from_cursor

    def move_to_start_of_line
      print "\e[0G"
    end
    module_function :move_to_start_of_line

    def move_up(rows = 1)
      return unless rows > 0
      print "\e[#{rows}A"
    end
    module_function :move_up

    def move_down(rows = 1)
      return unless rows > 0
      print "\e[#{rows}B"
    end
    module_function :move_down

    def move_right(columns = 1)
      return unless columns > 0
      print "\e[#{columns}C"
    end
    module_function :move_right

    def move_left(columns = 1)
      return unless columns > 0
      print "\e[#{columns}D"
    end
    module_function :move_left

    def cursor_position
      result = ""
      $stdin.raw do |stdin|
        $stdout << "\e[6n"
        $stdout.flush
        while (c = stdin.getc) != 'R'
          result << c if c
        end
      end
      matches = result.match /(?<row>\d+);(?<column>\d+)/

      [
        Integer(matches[:column]),
        Integer(matches[:row])
      ]
    end
    module_function :cursor_position
  end
end
