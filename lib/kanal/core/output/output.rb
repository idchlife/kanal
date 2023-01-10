# frozen_string_literal: true

require_relative "../helpers/parameter_finder_with_method_missing_mixin"
require_relative "../helpers/parameter_bag_with_registrator"

module Kanal
  module Core
    module Output
      # Base class for constructing output that will be given
      # from router node
      class Output
        include Helpers
        include Helpers::ParameterFinderWithMethodMissingMixin

        attr_reader :input, :core

        def initialize(parameter_registrator, input, core)
          @input = input
          @core = core
          @parameter_bag = ParameterBagWithRegistrator.new parameter_registrator
        end

        def configure_dsl(&block)
          instance_eval(&block)
        end

        private :core
      end
    end
  end
end
