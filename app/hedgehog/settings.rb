module Hedgehog
  class Settings
    def self.shared_instance
      @shared_instance ||= new
    end

    def self.configure
      yield(shared_instance)
    end

    attr_accessor :binary_in_path_finder
    attr_accessor :disabled_built_ins
    attr_accessor :execution_order
    attr_accessor :input_history

    # Disables user input/interaction.
    #
    # E.g. to require elsewhere, or for specs.
    #
    attr_accessor :disable_interaction
  end
end
