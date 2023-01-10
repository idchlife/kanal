# frozen_string_literal: true

module Kanal
  module Core
    module Helpers
      # Generic parameter bag class that stores named parameters
      class ParameterBag
        def initialize
          @parameters = {}
        end

        def get(name)
          @parameters[name]
        end

        def set(name, value)
          @parameters[name] = value
        end
      end
    end
  end
end
