module Hedgehog
  class State
    def self.shared_instance
      @shared_instance ||= new
    end

    def env
      @env ||= Bundler.clean_env
    end

    def aliases
      @aliases ||= {}
    end

    attr_accessor :prompt
    def prompt
      @prompt ||= lambda {}
    end
  end
end
