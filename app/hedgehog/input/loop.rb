module Hedgehog
  module Input
    class Loop
      def await_user_input
        multiline_handler = MultilineHandler.new
        while line = Readline.readline(get_prompt, true, multiline_handler: multiline_handler)
          Terminal.notify_current_working_directory
          runner.run(line)
        end
      rescue Interrupt
        puts
        retry
      end

      private

      FALLBACK_PROMPT = "> "

      def get_prompt
        Hedgehog::Process.retain_status_values do
          Hedgehog::State.shared_instance.prompt.call
        end || FALLBACK_PROMPT
      rescue Interrupt
        retry
      rescue
        puts "Failed to execute the prompt block. Check your Hedgehog configuration file. You can check the output by running `prompt.call`."
        FALLBACK_PROMPT
      end

      def runner
        @runner ||= Hedgehog::Execution::Runner.new
      end
    end
  end
end
