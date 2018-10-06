module Hedgehog
  module DSL
    def run(command_string)
      Hedgehog::Execution::Runner.new.run(command_string)
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
