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
      system("tput civis")
    end
    module_function :hide_cursor

    def show_cursor
      system("tput cnorm")
    end
    module_function :show_cursor

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
