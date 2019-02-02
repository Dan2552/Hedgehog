module Hedgehog
  module StringExtensions
    # Returns a String with it's terminal color characters stripped out.
    #
    # TODO: spec
    #
    def without_color(str)
      # str.gsub(/\e\[(\d+)(;\d+)*m/, "").gsub("\e[m", "")
      str.gsub(/\x1B\[([0-9]{1,3}((;[0-9]{1,3})*)?)?[m|K]/, "")
    end
    module_function :without_color

    def with_color(str, color: nil, bg_color: nil)
      color = "\x1b[38;5;#{color}m" if color
      bg_color = "\x1b[48;5;#{bg_color}m" if bg_color
      reset = "\x1b[0m"
      "#{color}#{bg_color}#{str}#{reset}"
    end
    module_function :with_color
  end
end
