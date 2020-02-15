module Hedgehog
  module Input
    module Readline
      def self.readline(prompt, add_history = false, multiline_handler: nil)
        editor = Hedgehog::Input::LineEditor.new(prompt, multiline_handler)

        Hedgehog::Terminal.raw!
        line = editor.edit_line
        Hedgehog::Terminal.cooked!
        puts ""

        if add_history
          history = Hedgehog::Settings.shared_instance.input_history
          history << line if history
        end

        line
      rescue Hedgehog::Input::EndOfFile
        nil
      ensure
        Hedgehog::Terminal.cooked!
      end
    end
  end
end
