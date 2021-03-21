require 'rspec/mocks/standalone'
module Hedgehog
  module Process
    module_function

    # This method can be used to spawn subprocesses without affecting the `#pid`
    # and `#exitstatus` values of `$?`.
    #
    # Because `$?` itself cannot be overriden. This method stubs the values over
    # the `Process::Status` instance that it returns.
    #
    def retain_status_values(&blk)
      previous_status = $?
      begin
        yield
      ensure
        return if $? == nil

        if previous_status
          pid = previous_status.pid
          exitstatus = previous_status.exitstatus
          inspect_value = previous_status.inspect
          to_s_value = "exit #{exitstatus}"
        else
          pid = nil
          exitstatus = nil
          inspect_value = "#<Process::Status: no process>"
          to_s_value = "no process"
        end

        $?.define_singleton_method(:pid, proc { pid })
        $?.define_singleton_method(:exitstatus, proc { exitstatus })
        $?.define_singleton_method(:inspect, proc { inspect_value })
        $?.define_singleton_method(:to_s, proc { to_s_value })
      end
    end
  end
end
