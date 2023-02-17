# frozen_string_literal: true

module Kanal
  module Core
    module Helpers
      # Module assumes that class where it was included has methods
      # set(name, value)
      # get(name)
      # transforms unknown methods to setters/getters for parameters
      module ParameterFinderWithMethodMissingMixin
        def method_missing(symbol, *args)
          parameter_name = symbol.to_s
          parameter_name.sub! "=", ""

          parameter_name = parameter_name.to_sym

          # standard workflow with settings properties with
          # input.prop = 123
          if symbol.to_s.include? "="
            @parameter_bag.set parameter_name, args.first
          elsif !args.empty?
            # this approach can be used also in dsl
            # like that
            # setters: prop value
            # getters: prop
            @parameter_bag.set(parameter_name, *args)
          # means it is used as setter in dsl,
          # method call with argument
          else
            @parameter_bag.get parameter_name
          end
        end
      end
    end
  end
end
