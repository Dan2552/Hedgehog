module Hedgehog
  module Input
    class Characters
      # How long to wait before determining the character is actually escape
      # in seconds.
      #
      ESCAPE_WAIT_LIMIT = 0.2

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
        characters ||= []
        characters << input_source.getc

        if characters.first == "\e"
          # Because escaped sequences start with, well, escape we actually don't
          # really know whether the first character is from a sequence or just
          # an escape keypress. The workaround is to wait and see.
          thread = Thread.new {
            characters << input_source.getc.chr
            representation = Character.new(characters.join(""))

            if representation.is?(:option_left) || representation.is?(:option_right)
              # escape early
            else
              characters << input_source.getc.chr
              characters << input_source.getc.chr if characters == ["\e", "[", "3"]
              3.times { characters << input_source.getc.chr } if characters.join("").start_with?("\e[1")
            end
          }
          thread.join(ESCAPE_WAIT_LIMIT)
          thread.kill
        end

        result = Character.new(characters.join(""))
        result
      end

      private

      def input_source
        Hedgehog::Settings.shared_instance.input_source || STDIN
      end
    end
  end
end
