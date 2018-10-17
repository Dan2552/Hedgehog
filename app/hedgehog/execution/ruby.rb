module Hedgehog
  module Execution
    class Ruby
      class Binding
        def self.shared_instance
          @shared_instance ||= new
        end

        def _run(str)
          _binding.eval(str)
        end

        private

        def _binding
          @_binding ||= binding
        end
      end

      def validate(command)
        true
      end

      def run(command)
        puts "=> #{Hedgehog::Execution::Ruby::Binding.shared_instance._run(command.original).inspect}"
      rescue Exception => e
        puts e
      end
    end
  end
end
