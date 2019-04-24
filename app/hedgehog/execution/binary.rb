module Hedgehog
  module Execution
    class Binary
      def validate(command)
        command.binary_path.present?
      end

      def run(command)
        begin
          # To set the $? variable for the process, we first run an exit.
          #
          # e.g `$(exit 12); echo $?` will print 12
          set_previous_status = "$(exit #{$?&.exitstatus || 0}); "

          # Prevents processes from detecting they're not interacting with TTY
          # (if they could, they generally don't print color characters).
          #
          # A PTY could be instead used, but then vi doesn't recognise the
          # correct size of the terminal.
          #
          # If /dev/tty were used as the argument here instead of /dev/null,
          # output would go directly to terminal, however then wouldn't work
          # when using commands with pipes (e.g. "command | grep xyz").
          #
          enforce_color = "script -q -t 0 /dev/null "

          # to_execute = set_previous_status +
          #   shared_variables +
          #   enforce_color +
          #   command.with_binary_path

          pid = Process.spawn(set_previous_status + command.with_binary_path)
          Process.wait(pid)

          # output = ""
          # io_r, io_w = IO.pipe
          # pid = Process.spawn(to_execute, out: io_w, err: [:child, :out])
          # io_w.close
          # while c = io_r.getc
          #   print c
          #   output += c
          # end
          # Process.wait(pid)
          # print "⏎\r\n" unless output.end_with?("\r\n") || output.empty?

          # Hedgehog::Execution::Ruby::Binding
          #   .shared_instance
          #   ._binding
          #   .local_variable_set(:_, output)
        end
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

        value = ""
        vars.each.with_index do |var, index|
          var_name = var.to_s.sub("$", "")
          str_value = values[index].gsub("'", "\"")
          value += "#{var_name}='#{str_value}';"
        end
        value
      end
    end
  end
end
