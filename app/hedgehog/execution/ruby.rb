module Hedgehog
  module Execution
    class Ruby
      def validate(command)
        true
      end

      def run(command)
        puts "=> #{eval(command.original)}"
      rescue Exception => e
        puts e
      end
    end
  end
end
