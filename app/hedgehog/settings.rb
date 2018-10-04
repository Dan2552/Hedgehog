module Hedgehog
  class Settings
    def self.shared_instance
      @shared_instance ||= new
    end

    def self.configure
      yield(shared_instance)
    end

    attr_accessor :binary_in_path_finder,
                  :disabled_built_ins,
                  :execution_order
  end
end
