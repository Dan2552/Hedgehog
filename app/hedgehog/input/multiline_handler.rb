module Hedgehog
  module Input
    class MultilineHandler
      def should_newline?(text)
        Hedgehog::Command.new(text).incomplete?
      end
    end
  end
end
