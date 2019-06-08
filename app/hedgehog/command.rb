module Hedgehog
  class Command
    # I.e. will only match spaces that don't have a proceeding `\`
    #
    UNESCAPED_SPACES_REGEX = /(?<!\\)(?:\\{2})*\ /

    # I.e. will only match spaces that aren't quoted around
    #
    WORD_REGEX = /\s(?=(?:[^"]|"[^"]*")*$)/

    # Combination of UNESCAPED_SPACES_REGEX and WORD_REGEX
    #
    UNESCAPED_WORD_REGEX = /(?<!\\)(?:\\{2})*\s(?=(?:[^"]|"[^"]*")*$)/

    class Arguments
      def initialize(array)
        @array = array
      end

      def to_s
        @array.join(" ")
      end

      def to_a
        @array
      end

      def to_i
        to_s.to_i
      end

      def method_missing(sym, *args, &blk)
        to_a.send(sym, *args, &blk)
      end
    end

    def initialize(command = "")
      @original = command.lstrip
      work_it_out
    end

    def binary_name
      @binary_name
    end

    def binary_path
      @binary_path
    end

    def original
      @original
    end

    def with_binary_path
      [
        env_vars,
        binary_path,
        arguments.to_s
      ].flatten.join(" ")
    end

    # TODO: for spec:
    # echo "hello  world"
    def arguments
      args = if @arguments_range
               original.split(UNESCAPED_WORD_REGEX)[@arguments_range]
             else
               []
             end

      Hedgehog::Command::Arguments.new(args)
    end

    def incomplete?
      last_line_has_backslash_at_end? ||
        (binary_path.present? && invalid_bash_command?)
    end

    def env_vars
      return [] unless @env_vars_range
      original.split(" ")[@env_vars_range]
    end

    private

    attr_reader :command_parts

    # TODO: for spec:
    # TEST=test ruby -e "puts ENV['TEST']"
    # bash -c "echo test"
    # /bin/bash -c "echo test"
    def work_it_out
      @binary_name = nil
      @binary_path = nil
      @arguments_range = nil
      @env_vars_range = nil

      original.split(" ").each.with_index do |word, index|
        if word.match(/^[\w|-]+$/) || File.file?(word)
          if File.file?(word)
            @binary_name = word.split("/").last
            @binary_path = word
          else
            @binary_name = word
            @binary_path = path_finder.call(binary_name) if path_finder
          end

          @arguments_range = ((index + 1)..-1)
          @env_vars_range = (0...index) unless index == 0

          return
        end
      end
    end

    def path_finder
      Hedgehog::Settings
        .shared_instance
        .binary_in_path_finder
    end

    def last_line_has_backslash_at_end?
      last_line = original.split("\n").compact.last
      return false if last_line.nil?
      last_line.match(/\\\s*$/) != nil
    end

    def invalid_bash_command?
      result = nil

      Hedgehog::Process.retain_status_values do
        cmd = ["bash", "-c", "-n", with_binary_path]
        result = IO.popen(cmd, 'r+', err: File::NULL) do |io|
          io.close_write
          io.read
        end

        result = $?.exitstatus != 0
      end

      result
    end
  end
end
