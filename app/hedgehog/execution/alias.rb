module Hedgehog
  module Execution
    class Alias
      def validate(command)
        aliases[command.binary_name.to_s].present?
      end

      def run(command)
        aliases[command.binary_name.to_s].call(command.arguments)
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
      end

      private

      def aliases
        Hedgehog::State
          .shared_instance
          .aliases
      end
    end
  end
end
