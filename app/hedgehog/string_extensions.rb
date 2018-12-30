module Hedgehog
  module StringExtensions
    # Returns a String with it's terminal color characters stripped out.
    #
    # TODO: spec
    #
    def without_color(str)
      str.gsub(/\e\[(\d+)(;\d+)*m/, "").gsub("\e[m", "")
    end
    module_function :without_color
  end
end
