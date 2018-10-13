module Hedgehog
  module Input
    class Characters
      class Character
        def initialize(string)
          @string = string
        end

        # E.g. giving `:up` will return true if char is "\e[A"
        def is?(key)
          Hedgehog::Input::Mapping::KNOWN_KEYS[@string] == key
        end

        def known_special?
          Hedgehog::Input::Mapping::KNOWN_KEYS[@string].present?
        end

        def unknown?
          Hedgehog::Input::Mapping::KNOWN_KEYS[@string].nil? && to_s.length > 1
        end

        def to_s
          @string.to_s
        end

        def method_missing(sym, *args, &blk)
          @string.send(sym, *args, &blk)
        end
      end

      def get_next
        characters << STDIN.getc

        return get_next if expecting_more_characters?

        result = Character.new(characters.join(""))
        @characters = nil
        result
      end

      private

      def characters
        @characters ||= []
      end

      # ["\e", "[", "A"] => :up
      # ["\e", "[", "B"] => :down
      # ["\e", "[", "C"] => :right
      # ["\e", "[", "D"] => :left
      # ["\u0003"] => :ctrl_c
      # ["\u0004"] => :ctrl_d
      #
      def expecting_more_characters?
        return false unless characters.first == "\e"
        return false if characters.last.match(/[a-zA-Z]/)
        true
      end
    end
  end
end
