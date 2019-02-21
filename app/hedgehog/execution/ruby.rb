module Hedgehog
  module Execution
    class Ruby
      class Binding
        def self.shared_instance
          @shared_instance ||= new
        end

        def _run(str)
          _binding.eval(str)
        rescue Exception => e
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
        puts "=> #{Hedgehog::Execution::Ruby::Binding.shared_instance._run(command.original).inspect}"
      rescue Exception => e
        puts e
      end
    end
  end
end
