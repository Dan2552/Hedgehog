module Hedgehog
  class Input
    def await_user_input
      @show_prompt = true
      while true
        command_string = Readline.readline(get_prompt, true)
        Bundler.send(:with_env, env) do
          result = runner.run(command_string)
          @show_prompt = result
        end
      end
    rescue Interrupt
      puts ""
      await_user_input
    end

    private

    def get_prompt
      if @show_prompt
        prompt.call
      else
        ""
      end
    end

    def runner
      @runner ||= Hedgehog::Execution::Runner.new
    end

    def env
      Hedgehog::State.shared_instance.env
    end
  end
end
