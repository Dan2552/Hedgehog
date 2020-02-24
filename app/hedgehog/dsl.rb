module Hedgehog
  module DSL
    module_function

    def run(command_string)
      Hedgehog::Execution::Runner.run(command_string)
    end

    def binary_run(command_string)
      puts "Hedgehog: binary_run is deprecated, use shell_run instead"
      shell_run(command_string)
    end

    def shell_run(command_string)
      command = Hedgehog::Command.new(command_string)
      Hedgehog::Execution::Shell.new.run(command)
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
  end
end
