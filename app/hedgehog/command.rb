module Hedgehog
  class Command
    class Arguments < SimpleDelegator
      def to_s
        join(" ")
      end

      def [](*args)
        Arguments.new(super(*args))
      end
    end
# TODO: kill off these constants
    # I.e. will only match spaces that don't have a proceeding `\`
    #
    UNESCAPED_SPACES_REGEX = /(?<!\\)(?:\\{2})*\ /

    # I.e. will only match spaces that aren't quoted around
    #
    WORD_REGEX = /\s(?=(?:[^"]|"[^"]*")*$)/

    # Combination of UNESCAPED_SPACES_REGEX and WORD_REGEX
    #
    UNESCAPED_WORD_REGEX = /(?<!\\)(?:\\{2})*\s(?=(?:[^"]|"[^"]*")*$)/

    # String
    #
    attr_reader :original

    def initialize(original, ast = nil)
      @original = original

      if ast
        @ast = ast
      else
        tokens = Hedgehog::Parse::Tokens.new(original).tokenize
        @ast = Hedgehog::Parse::Parser.new(tokens).parse
      end

      first = @ast.children.first

      case first&.type
      when :pipe, :or, :and
        first = first
          .children
          .find { |leaf| leaf.type == :lhs }
          .children
          .find { |leaf| leaf.type == :command}
      end

      if first&.type == :command
        @command = first
        @arguments = @command.children.select { |leaf| leaf.type == :argument }
        @env_vars = @command.children.select { |leaf| leaf.type == :env_var }
      end
    rescue Hedgehog::Parse::UnexpectedToken => e
      Hedgehog::Terminal.cooked!
      print "\x1b[38;5;8m"
      puts
      puts e
      puts e.backtrace[0..1]
        .map { |s| s.gsub("/Users/dan2552/Dropbox/Hedgehog/", "") }
        .select { |s| !s.include?("base_handler.rb") }
      puts
      print "\x1b[0m"
      @expecting_something_before_eof = true
    end

    # This is Hedgehog's main concern on the command: Should this command be
    # treated as a regular shell command, or as Ruby?
    #
    def treat_as_shell?
      binary_path.present?
    end

    # This is to be used to determine whether the Hedgehog editor should
    # continue to a newline (i.e. a multi-lined command), or whether it should
    # execute as-is.
    #
    def expecting_something_before_eof?
      @expecting_something_before_eof || false
    end

    # Multiple commands sequentially. E.g. `echo x; echo y`
    #
    def sequential?
      @ast.children.count > 1
    end

    def sequence
      sequence = @ast.children
        .select { |leaf| leaf.type == :command }
        .map do |leaf|
          root = Hedgehog::Parse::Leaf.new(:root, nil)
          root.children << leaf
          self.class.new(leaf.to_s, root)
        end
    end

    def piped?
      @ast.children.count == 1 &&
        @ast.children.first.type == :pipe
    end

    def operation_parts
      return nil unless piped? || binary_operation?

      binary_operator = @ast.children.first
      lhs = binary_operator.children.find { |leaf| leaf.type == :lhs }.to_s
      rhs = binary_operator.children.find { |leaf| leaf.type == :rhs }.to_s

      {
        operator: binary_operator.type,
        lhs: lhs,
        rhs: rhs
      }
    end

    def binary_operation?
      case @ast&.children&.first&.type
      when :or, :and
        true
      else
        false
      end
    end

    def arguments_collection
      Arguments.new(@arguments&.map(&:to_s) || [])
    end

    def expanded
      return original unless @command
      following_arguments = @arguments[1..-1].map(&:to_s).join(" ")
      env_vars = @env_vars.map(&:to_s).join(" ")

      puts "{{{ #{env_vars} #{binary_path} #{following_arguments} }}}".strip

      "#{env_vars} #{binary_path} #{following_arguments}".strip
    end

    def binary_name
      @arguments&.first.to_s
    end

    private

    attr_reader :ast

    def binary_path
      return nil unless binary_name.present?

      # If binary name is a path to the binary already
      return binary_name if File.file?(binary_name)

      path_finder = Hedgehog::Settings
        .shared_instance
        .binary_in_path_finder

      return nil unless path_finder.respond_to?(:call)

      path_finder.call(binary_name)
    end
  end
end
