module Hedgehog
  module BinaryInPathFinder
    class Which
      def call(binary)
        `which #{binary}`.chomp.presence
      end
    end
  end
end
