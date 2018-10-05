module Hedgehog
  module Environment
    class Path
      def self.all
        ENV['PATH'].split(":")
      end

      def self.binaries
        all.map { |path| Dir["#{path}/*"] }
          .flatten
          .select { |path| File.file?(path) && File.executable?(path) }
      end
    end
  end
end
