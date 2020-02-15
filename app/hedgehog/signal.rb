module Hedgehog
  class Signal
    def self.subscribe(type, key, &blk)
      start
      subscriptions[type][key] = blk
    end

    def self.unsubscribe(type, key)
      subscriptions[type].delete(key)
    end

    # To be called by the signal trap.
    #
    def self.sigwinch(_)
      subscriptions[:sigwinch].each { |_, blk| blk.call }
    end

    private

    def self.subscriptions
      @subscriptions ||= {}
      @subscriptions[:sigwinch] ||= {}
      @subscriptions
    end

    def self.start
      return if @started == true
      @started = true

      ::Signal.trap('SIGWINCH', method(:sigwinch))
    end
  end
end
