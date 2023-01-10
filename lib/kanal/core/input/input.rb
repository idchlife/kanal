# frozen_string_literal: true

require_relative "../helpers/parameter_finder_with_method_missing_mixin"
require_relative "../helpers/parameter_bag_with_registrator"

module Kanal
  module Core
    module Input
      # This class contains all the needed input properties
      class Input
        include Helpers
        include Helpers::ParameterFinderWithMethodMissingMixin

        def initialize(parameter_registrator)
          @parameter_bag = ParameterBagWithRegistrator.new parameter_registrator
        end
      end
    end
  end
end
