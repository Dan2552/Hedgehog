module Hedgehog
  module Input
    class Mapping
      KNOWN_KEYS = {
        "\e[A" => :up,
        "\e[B" => :down,
        "\e[C" => :right,
        "\e[D" => :left,
        "\u0003" => :ctrl_c,
        "\u0004" => :ctrl_d,
        "\u007F" => :backspace,
        "\n" => :enter,
        "\r" => :enter,
      }
    end
  end
end
