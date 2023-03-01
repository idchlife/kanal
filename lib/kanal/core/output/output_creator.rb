# frozen_string_literal: true

module Kanal
  module Core
    module Output
      # This class helps creating output with the help
      # of handy dsl format
      class OutputCreator
        def initialize(input)
          @input = input
        end

        def create(&block); end
      end
    end
  end
end
