module Hedgehog
  module Parse
    class EnvVarHandler < BaseHandler
      def handle_token
        log "handling env var"

        case current_token.type
        when :word_starting_with_letter # TODO: , :word_starting_with_number, etc
          add_leaf(:env_var_rhs, current_token)
        else
          raise ":( handle_env_var: #{current_token}"
        end
      end
    end
  end
end
