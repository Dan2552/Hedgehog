module Hedgehog
  module Terminal
    def columns
      `tput cols`.chomp.to_i
    end
    module_function :columns

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
