module Hedgehog
  module Parse
    class Parser
      class Leaf
        def initialize(type, token)
          @type = type
          @token = token
        end

        def children
          @children ||= []
        end

        def structure
          if children.count > 0
            {
              type => children.map(&:structure)
            }
          else
            type
          end
        end

        attr_accessor :type
        attr_accessor :token
      end

      def initialize(tokens)
        @tokens = tokens
        @current_state = :normal
        @current_leaf = @root = Leaf.new(:root, nil)
      end

# :word_starting_with_letter
# :space
# :number
# :word_starting_with_number
# :equals
# :single_quote
# :double_quote
# :backtick
# :pipe

      # Parsing produces a tree.
      #
      def parse
        raise "Expected :end at the end of the token list" if tokens.last.type != :end
        puts "\n\nSTART----------------"
        tokens.each do |t|
          @current_token = t
          handle_token
        end
        puts "ENDED----------------\n\n"
        @root
      end

      private

      attr_reader :tokens


      attr_reader :current_state
      attr_reader :current_token
      attr_reader :current_leaf

      def handle_token
        puts "current state: #{current_state}"
        case current_state
        when :normal
          handle_normal
        when :maybe_env_maybe_command
          handle_maybe_env_maybe_command
        end
      end

      # normal: we're looking for either:
      # - environment variables
      # - command name (binary/alias/etc) to run
      #
      def handle_normal
        puts "  handling normal"
        case current_token.type
        when :word_starting_with_letter
          puts "    At this point we don't know whether this is an env var or a command"
          @current_state = :maybe_env_maybe_command
          add_leaf(:undecided, current_token, make_new_current: true)
        when :word_starting_with_number
          # This has to be a command
        else
          raise ":( handle_normal: #{current_token}"
        end
      end

      def handle_maybe_env_maybe_command
        puts "  handling possible env var / command"
        case current_token.type
        when :word_starting_with_letter
          puts "    must've been a command as an argument was supplied"
          current_leaf.type = :command
          add_leaf(:argument, current_token)
        when :end
          puts "    must've been a command as it's the end"
          current_leaf.type = :command
        end
      end

      def add_leaf(type, token, make_new_current: false)
        puts "    new leaf: #{type}"
        new_leaf = Leaf.new(type, token)
        current_leaf.children << new_leaf
        @current_leaf = new_leaf if make_new_current
        new_leaf
      end
    end
  end
end
