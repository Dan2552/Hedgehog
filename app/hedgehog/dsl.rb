module Hedgehog
  module DSL
    def run(command_string)
      _runner.run(command_string)
    end

    def binary_run(command_string)
      command = Hedgehog::Command.new(command_string)
      Hedgehog::Execution::Binary.new.run(command)
    end

    def prompt(&blk)
      state = Hedgehog::State.shared_instance

      if block_given?
        state.prompt = blk
      else
        state.prompt
      end
    end

    def function(name, &blk)
      state = Hedgehog::State.shared_instance

      if block_given?
        state.aliases ||= {}
        state.aliases[name] = blk
      else
        state.aliases[name]
      end
    end

    private

    def _runner
      @_runner ||= Hedgehog::Execution::Runner.new
    end
  end
end
