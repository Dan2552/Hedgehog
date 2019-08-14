require 'pty'
require 'io/console'

module Hedgehog
  module Execution
    class Binary
      def validate(command)
        command.binary_path.present?
      end

      def run(command)
        # To set the $? variable for the process, we first run an exit.
        #
        # e.g `$(exit 12); echo $?` will print 12
        set_previous_status = "$(exit #{$?&.exitstatus || 0}); "
        to_execute = set_previous_status + command.with_binary_path

        output = ""

        master, slave = PTY.open

        IO.console.raw!

        input_thread = nil
        pid = ::Process.spawn(shared_variables, to_execute, :in => slave, [:out, :err] => slave)
        slave.close
        master.winsize = $stdout.winsize
        Signal.trap(:WINCH) { master.winsize = $stdout.winsize }
        Signal.trap(:SIGINT) { ::Process.kill("INT", pid) }

        input_thread = Thread.new { IO.copy_stream(STDIN, master) }

        master.each_char do |char|
          STDOUT.print char
          output.concat(char)
        end

        ::Process.wait(pid)
        IO.console.cooked!
        master.close
        input_thread.kill if input_thread

        print "⏎\n" unless output.end_with?("\n") || output.empty?

        Hedgehog::Execution::Ruby::Binding
          .shared_instance
          ._binding
          .local_variable_set(:_, output)
      ensure
        ::Process.wait rescue SystemCallError
      end

      private

      DEFAULT_GLOBAL_VARIABLES = [
        :$LOAD_PATH,
        :$",
        :$LOADED_FEATURES,
        :$-I,
        :$-p,
        :$-l,
        :$-a,
        :$binding,
        :$@,
        :$!,
        :$stdin,
        :$stdout,
        :$stderr,
        :$>,
        :$<,
        :$.,
        :$FILENAME,
        :$-i,
        :$*,
        :$SAFE,
        :$_,
        :$~,
        :$$,
        :$?,
        :$;,
        :$-F,
        :$&,
        :$`,
        :$',
        :$=,
        :$KCODE,
        :$+,
        :$-K,
        :$,,
        :$/,
        :$-0,
        :$\,
        :$VERBOSE,
        :$-v,
        :$-w,
        :$-W,
        :$DEBUG,
        :$-d,
        :$0,
        :$PROGRAM_NAME,
        :$:
      ]

      def shared_variables
        vars = global_variables - DEFAULT_GLOBAL_VARIABLES
        values = vars.map { |x| eval(x.to_s).to_s }

        shared_variables = {}
        vars.each.with_index do |var, index|
          var_name = var.to_s.sub("$", "")
          str_value = values[index]
          shared_variables[var_name] = str_value
        end

        shared_variables
      end
    end
  end
end
