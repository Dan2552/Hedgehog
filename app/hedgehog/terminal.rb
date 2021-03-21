module Hedgehog
  module Terminal
    def self.title=(str)
      print "\033]0;#{str}\007"
    end

    # Input like directional keys are silenced so they can be used to control
    # the input editor.
    #
    def self.silence!
      # Specifically does _not_ use `IO.console.raw!` because it apparently
      # gobbles up all STDIN that's currently in queue. Which is no good,
      # because we want characters typed before Hedgehog loads.
      Hedgehog::Process.retain_status_values do
        system("stty raw -echo")
      end
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

    # The macOS Terminal app specifically uses this to determine what to open
    # when a new tab is spawned.
    #
    # Some other terminal emulators (e.g. iTerm) actually use the process' cwd
    # value instead, so don't need this.
    #
    # This is basically a re-implementation of `update_terminal_cwd` commonly
    # defined in `/etc/bashrc_Apple_Terminal`.
    #
    def self.notify_current_working_directory
      pwd = Dir.pwd
      url_path = pwd.each_char.map do |char|
        if char =~ /[\/._~A-Za-z0-9-]/
          char
        else
          ERB::Util.url_encode(char)
        end
      end.join

      print "\e]7;file://#{ENV['HOSTNAME']}#{url_path}\a"
    end
  end
end
