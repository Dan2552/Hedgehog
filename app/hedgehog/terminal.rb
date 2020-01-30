module Hedgehog
  module Terminal
    def self.title=(str)
      print "\033]0;#{str}\007"
    end

    # Input like directional keys are silenced so they can be used to control
    # the input editor.
    #
    def self.silence!
      IO.console.raw!
    end

    # Restores silenced state. See `silence!` for more info.
    #
    def self.restore!
      IO.console.cooked!
    end

    def self.columns
      ENV['COLUMNS']&.to_i || IO.console.winsize[1] || 80
    end

    def self.rows
      ENV['LINES']&.to_i || IO.console.winsize[0] || 24
    end

    def self.hide_cursor
      print "\e[?25l"
    end

    def self.show_cursor
      print "\e[?25h"
    end

    def self.clear_screen_from_cursor
      print "\e[0J"
    end

    def self.move_to_start_of_line
      print "\e[0G"
    end

    def self.move_up(rows = 1)
      return unless rows > 0
      print "\e[#{rows}A"
    end

    def self.move_down(rows = 1)
      return unless rows > 0
      print "\e[#{rows}B"
    end

    def self.move_right(columns = 1)
      return unless columns > 0
      print "\e[#{columns}C"
    end

    def self.move_left(columns = 1)
      return unless columns > 0
      print "\e[#{columns}D"
    end
  end
end
