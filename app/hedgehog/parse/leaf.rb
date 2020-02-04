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

      attr_reader :type
      attr_reader :token
    end
  end
end
