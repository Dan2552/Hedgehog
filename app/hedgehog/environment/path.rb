module Hedgehog
  module Environment
    class Path
      def self.all
        ENV['PATH'].split(":")
      end

      def self.binaries
        all.map { |path| Dir["#{path}/*"] }.flatten
      end
    end
  end
end
