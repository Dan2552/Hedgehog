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
        check_exit_status = $?
        prompt = Hedgehog::State.shared_instance.prompt.call || "> "

        if check_exit_status && check_exit_status != $?
          system("exit #{check_exit_status.exitstatus}")
          warn_about_dollar_questionmark_limitation
        end

        prompt
      rescue
        "> "
      end

      def runner
        @runner ||= Hedgehog::Execution::Runner.new(is_history_enabled: true)
      end

      def warn_about_dollar_questionmark_limitation
        return if Hedgehog::Settings.shared_instance.disable_prompt_execution_warning

        puts "Warning: A limitation in Ruby prevents Hedgehog overriding `$?`. " +
             "Because your custom prompt spawned a new process, the exitstatus " +
             "and pid of the previous command ran in the command line has just " +
             "been overwritten. However, Hedgehog can (and just has) restored " +
             "the exitstatus. If you're ok with losing the pid, you can prevent " +
             "this warning ever showing by putting the following in your " +
             "`.hedgehog` file:" +
             "\n" +
             "```\n" +
             "Hedgehog::Settings.configure do |config|\n" +
             "  config.disable_prompt_execution_warning = true\n" +
             "end\n" +
             "```\n"
      end
    end
  end
end
