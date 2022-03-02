module Hedgehog
  # Port from the Pelican project - https://github.com/Dan2552/pelican
  module WordBoundary
    class << self
      # Finds a word boundary in a string.
      #
      # * text: String
      # * index: Integer
      # * rightwards: Boolean
      #
      def find_word_boundary(text, index, rightwards)
        has_seen_at_least_one_non_boundary = false
        only_whitespace_boundaries = true

        if rightwards
          while index < text.length
            character = text[index]
            if !(is_alphanumeric(character) || character == "_")
              whitespace = is_whitespace(character)

              only_whitespace_boundaries = false unless whitespace

              # if we've seen anything that isn't whitespace before, but now
              # it's a whitespace, we end.
              if !only_whitespace_boundaries && whitespace
                break
              end

              # if we've seen a non-boundary character before and now we've
              # seen a boundary, we end.
              if has_seen_at_least_one_non_boundary
                break
              end
            else
              has_seen_at_least_one_non_boundary = true
              only_whitespace_boundaries = false
            end

            index = index + 1
          end
        else
          while index > 0
            character = text[index - 1]
            if !(is_alphanumeric(character) || character == "_")
                whitespace = is_whitespace(character)

                only_whitespace_boundaries = false unless whitespace

                # if we've seen anything that isn't whitespace before, but now
                # it's a whitespace, we end.
                if !only_whitespace_boundaries && whitespace
                  break
                end

                # if we've seen a non-boundary character before and now we've
                # seen a boundary, we end.
                if has_seen_at_least_one_non_boundary
                  break
                end
            else
              has_seen_at_least_one_non_boundary = true
              only_whitespace_boundaries = false
            end

            index = index - 1
          end
        end

        index
      end

      # Finds a line boundary in a string.
      #
      # * text: String
      # * start_index: Integer
      # * rightwards: Boolean
      #
      def find_line_boundary(text, start_index, rightwards)
        index = start_index
        vector = -1
        vector = 1 if rightwards

        loop do
          character = text[index]

          if rightwards
            break if index >= text.length
            break if character == "\n"
          else
            break if index <= 0
            break if text[index - 1] == "\n"
          end

          index = index + vector
        end

        index
      end

      private

      def is_alphanumeric(string)
        string.match?(/\A[a-zA-Z0-9]*\z/)
      end

      def is_whitespace(string)
        string.match?(/\A\s*\Z/)
      end
    end
  end
end
