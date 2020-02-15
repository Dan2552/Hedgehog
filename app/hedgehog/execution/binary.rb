require 'pty'
require 'io/console'

module Hedgehog
  module Execution
    class Binary
      def validate(command)
        command.binary_path.present?
      end

      def run(command)
        reset

        # To set the $? variable for the process, we first run an exit.
        #
        # e.g `$(exit 12); echo $?` will print 12
        set_previous_status = "$(exit #{$?&.exitstatus || 0})"

        # This command is run after the desired command to capture any STDIN
        # that wasn't consumed by the desired command, so it can be re-run.
        #
        # E.g. if you type `sleep 5` and you type before the process ends, it
        # will capture the input typed to send back to the shell.
        #
        # The $? is passed in as an arument so it can set the status back to the
        # original command's again.
        rehyrate = Bundler.root.join("bin", "rehydrate_stdin.rb").to_s + " $?"

        to_execute = [
          set_previous_status,
          command.with_binary_path,
          rehyrate
        ].join("; ")

        output = ""
        input_thread = nil
        IO.console.raw!

        input = Hedgehog::Settings.shared_instance.input_source&.reader || STDIN

        PTY.spawn(to_execute) do |read, write, pid|
          write.winsize = STDOUT.winsize
          Hedgehog::Signal.subscribe(:sigwinch, self) { write.winsize = STDOUT.winsize }
          input_thread = Thread.new { IO.copy_stream(input, write) }

          read.each_char do |char|
            output(char, output)
          end

          ::Process.wait(pid)
        end
        input_thread.kill if input_thread
        flush_output_queue(output)
        rehydrate_input

        IO.console.cooked!

        print "⏎\n" unless output.end_with?("\n") || output.empty?

        Hedgehog::Execution::Ruby::Binding
          .shared_instance
          ._binding
          .local_variable_set(:_, output)
      ensure
        Hedgehog::Signal.unsubscribe(:sigwinch, self)
        ::Process.wait rescue SystemCallError
      end

      private

      # Output to the real terminal, and save the output for the `_` variable.
      #
      # Contains special handling for `\[hedg` set of characters to handle the
      # STDIN rehydration.
      #
      def output(char, output)
        @output_queue ||= []
        if char == "\\" && @output_queue.empty?
          @output_queue << char
        elsif !@output_queue.empty?
          @output_queue << char

          return flush_output_queue(output) if @output_queue.count == 2 && @output_queue != ["\\", "["]
          return flush_output_queue(output) if @output_queue.count == 3 && @output_queue != ["\\", "[", "h"]
          return flush_output_queue(output) if @output_queue.count == 4 && @output_queue != ["\\", "[", "h", "e"]
          return flush_output_queue(output) if @output_queue.count == 5 && @output_queue != ["\\", "[", "h", "e", "d"]
          return flush_output_queue(output) if @output_queue.count == 6 && @output_queue != ["\\", "[", "h", "e", "d", "g"]
          return if @output_queue.count < 8
          @repopulate_stdin ||= []
          @repopulate_stdin << char
        else
          STDOUT.print(char)
          output.concat(char)
        end
      end

      def reset
        @output_queue = []
        @repopulate_stdin = []
      end

      # If any characters were held back previously as they were possibly
      # building up to the `\[hedg` escape code, print them out.
      #
      def flush_output_queue(output)
        return if @output_queue[0..5] == ["\\", "[", "h", "e", "d", "g"]

        @output_queue.each do |char|
          STDOUT.print(char)
          output.concat(char)
        end
        @output_queue = []
      end

      def rehydrate_input
        input_writer = Hedgehog::Settings.shared_instance.input_source&.writer
        return unless input_writer

        @repopulate_stdin.each do |char|
          input_writer.putc(char) unless char == "\r"
        end
      end
    end
  end
end
