module Hedgehog
  module Input
    class Loop
      def await_user_input
        @show_prompt = true
        loop do
          command_string = editor.readline(get_prompt)

          # CMD+D makes nil for some reason
          return if command_string.nil?

          result = runner.run(command_string)
          @show_prompt = result
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
        prompt = Hedgehog::State.shared_instance.prompt

        prompt_output = prompt.call || ""

        if @show_prompt
          prompt_output
        else
          colorless = prompt_output.gsub(/\e\[(\d+)(;\d+)*m/, "").gsub("\e[m", "")
          " " * colorless.length
        end
      end

      def runner
        @runner ||= Hedgehog::Execution::Runner.new(history: true)
      end
    end
  end
end
