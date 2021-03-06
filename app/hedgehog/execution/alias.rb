module Hedgehog
  module Execution
    class Alias
      def validate(command)
        there_is_an_alias = aliases[command.binary_name.to_s].present?
        path_is_supplied = command.binary_path && command.original.start_with?(command.binary_path)
        there_is_an_alias && !path_is_supplied
      end

      def run(command)
        output = aliases[command.binary_name.to_s].call(command.arguments)
        set_underscore(output)
      rescue LocalJumpError
        # Allow calls to `break`
      rescue Exception => e
        relevant_line = e
          .backtrace
          .select { |l| l.include?("#{ENV['HOME']}/.hedgehog") }
          .first
          &.sub(/:in .*/, "")
          &.sub(/^/, "error in ")

        puts e
        puts relevant_line
        set_underscore(nil)
      end

      private

      def aliases
        Hedgehog::State
          .shared_instance
          .aliases
      end

      def set_underscore(value)
        Hedgehog::Execution::Ruby::Binding
          .shared_instance
          ._binding
          .local_variable_set(:_, value)
      end
    end
  end
end
