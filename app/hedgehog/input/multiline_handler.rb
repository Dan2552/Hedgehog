module Hedgehog
  module Input
    class MultilineHandler
      def should_newline?(text)
        return true if Hedgehog::Command.new(text).expecting_something_before_eof?
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
