module Hedgehog
  module Environment
    module Path
      def all
        ENV['PATH'].split(":")
      end
      module_function :all

      def binaries
        all.map { |path| Dir["#{path}/*"] }
          .flatten
          .select { |path| File.file?(path) && File.executable?(path) }
      end
      module_function :binaries
    end
  end
end
