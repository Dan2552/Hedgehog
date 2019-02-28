require 'pty'
require 'io/console'

module Hedgehog
  module Input
    class PreemptiveInput
      def initialize
        start_listening
      end

      def close
        @thread.kill
        @io_r.close
        @io_w.close
      end

      def getc
        @io_r.getc
      end

      def reader
        @io_r
      end

      private

      def start_listening
        @io_r, @io_w = IO.pipe

        @thread = Thread.new do
          IO.copy_stream(STDIN, @io_w)
        end
      end
    end
  end
end
