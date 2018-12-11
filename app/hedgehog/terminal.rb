module Hedgehog
  module Terminal
    def columns
      IO.console.winsize[1]
    end
    module_function :columns

    def rows
      IO.console.winsize[0]
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
  end
end
