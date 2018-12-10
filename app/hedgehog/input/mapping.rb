module Hedgehog
  module Input
    class Mapping
      KNOWN_KEYS = {
        "\e" => :escape,
        "\e[A" => :up,
        "\e[B" => :down,
        "\e[C" => :right,
        "\e[D" => :left,
        "\e[1;3C" => :option_right,
        "\e[1;3D" => :option_left,
        "\u0003" => :ctrl_c,
        "\u0004" => :ctrl_d,
        "\u007F" => :backspace,
        "\n" => :enter,
        "\r" => :enter,
        "\t" => :tab,
        "\e[3~" => :delete
      }
    end
  end
end
