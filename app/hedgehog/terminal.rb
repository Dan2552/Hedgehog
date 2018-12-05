module Hedgehog
  module Terminal
    def columns
      @columns_last_update ||= 1.year.ago
      return @columns if Time.now < (@columns_last_update + 5.seconds)

      @columns_last_update = Time.now
      @columns = `tput cols`.chomp.to_i
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
