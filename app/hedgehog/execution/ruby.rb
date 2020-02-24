module Hedgehog
  module Execution
    class Ruby
      class Binding
        def self.shared_instance
          @shared_instance ||= new
        end

        def initialize
          _binding.local_variable_set(:_, nil)
        end

        def _run(str)
          _binding.eval(str)
          system("exit 0")
        rescue Exception => e
          system("exit 1")
          # In a shell we don't necessarily want a full exception. Especially
          # if they mislead the reason to point to Hedgehog internals.
          raise e.to_s
            .sub(/#{__FILE__}:\d*: /, '')
            .sub(/ for #<Hedgehog::Execution::Ruby::Binding:.*>/, '')
        end

        def _binding
          @_binding ||= binding
        end
      end

      def validate(command)
        true
      end

      def run(command)
        binding_instance = Hedgehog::Execution::Ruby::Binding.shared_instance
        return_value = binding_instance._run(command.original)
        puts "=> #{CodeRay.scan(return_value.inspect.to_s, :ruby).term}"
        binding_instance._binding.local_variable_set(:_, return_value)
      rescue Exception => e
        puts e
      end
    end
  end
end
