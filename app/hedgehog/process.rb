require 'rspec/mocks/standalone'
module Hedgehog
  module Process
    extend RSpec::Mocks::ExampleMethods

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
          allow($?)
            .to receive(:pid)
            .and_return(previous_status.pid)
          allow($?)
            .to receive(:exitstatus)
            .and_return(previous_status.exitstatus)
          allow($?)
            .to receive(:inspect)
            .and_return(previous_status.inspect)
        else
          allow($?)
            .to receive(:pid)
            .and_return(nil)
          allow($?)
            .to receive(:exitstatus)
            .and_return(nil)
          allow($?)
            .to receive(:inspect)
            .and_return("#<Process::Status: no process>")
        end
      end
    end
  end
end
