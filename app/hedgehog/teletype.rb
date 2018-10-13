module Hedgehog
  module Teletype
    def self.silence!
      system("stty raw -echo")
    end

    def self.restore!
      system("stty -raw echo")
    end
  end
end
