module Hedgehog
  module Input
    class Loop
      def await_user_input
        loop do
          command_string = editor.readline(get_prompt)

          # CMD+D makes nil for some reason
          return if command_string.nil?

          runner.run(command_string)
        end
      rescue Interrupt
        puts ""
        self.class.new.await_user_input
      end

      private

      def editor
        @editor ||= Hedgehog::Input::LineEditor.new
      end

      def get_prompt
        Hedgehog::State.shared_instance.prompt.call || "> "
      rescue
        "> "
      end

      def runner
        @runner ||= Hedgehog::Execution::Runner.new(is_history_enabled: true)
      end
    end
  end
end
