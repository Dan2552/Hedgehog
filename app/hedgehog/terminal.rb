module Hedgehog
  module Terminal
    def title=(str)
      print "\033]0;#{str}\007"
    end
    module_function :title=

    # Input like directional keys are silenced so they can be used to control
    # the input editor.
    #
    def silence!
      IO.console.raw!
    end
    module_function :silence!

    # Restores silenced state. See `silence!` for more info.
    #
    def restore!
      IO.console.cooked!
    end
    module_function :restore!

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
  end
end
