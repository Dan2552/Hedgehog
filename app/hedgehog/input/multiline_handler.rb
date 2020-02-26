module Hedgehog
  module Input
    class MultilineHandler
      def should_newline?(text)
        command = Hedgehog::Command.new(text)

        if command.treat_as_shell?
          return true if command.expecting_something_before_eof?
        else

        end

        last_line_has_backslash_at_end?(text)
      end

      private

      # TODO: Command should handle this in expecting_something_before_eof?
      def last_line_has_backslash_at_end?(text)
        last_line = text.split("\n").compact.last
        return false if last_line.nil?
        last_line.match(/\\\s*$/) != nil
      end
    end
  end
end
