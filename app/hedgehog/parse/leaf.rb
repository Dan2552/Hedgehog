module Hedgehog
  module Parse
    class Leaf
      def initialize(type, token)
        @type = type
        @token = token
      end

      def children
        @children ||= []
      end

      def structure
        if children.count == 0
          type
        elsif children.count > 1
          {
            type => children.map(&:structure)
          }
        else
          {
            type => children.first.structure
          }
        end
      rescue StandardError
        puts "Children: #{children}"
        raise
      end

      def to_s(replace_first_argument = nil)
# root: { command: [
#             :argument,
#             { argument: { string: [:string_part, :string_part, :string_part]}},
#             { argument: { string: [:string_part, :string_part, :string_part]}}
#           ] }
        case type
        when :command
          children.map(&:to_s).join(" ")
        when :argument, :argument_part, :lhs, :rhs, :string_part
          if token.present?
            token.text
          else
            children.map(&:to_s).join("")
          end
        when :string
          quote = token.text
          "#{quote}#{children.map(&:to_s).join("")}#{quote}"
        when :env_var
          lhs = children.find { |leaf| leaf.type == :lhs }
          rhs = children.find { |leaf| leaf.type == :rhs }
          "#{lhs}=#{rhs}"
        else
          raise "to_s for #{type}"
        end
      end

      attr_reader :type
      attr_reader :token
    end
  end
end
