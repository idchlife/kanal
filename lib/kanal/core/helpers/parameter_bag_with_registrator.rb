# frozen_string_literal: true

require_relative "parameter_bag"

module Kanal
  module Core
    module Helpers
      # Parameter bag but it checks registrator for existence of parameters
      # and if they are has needed by registrator allowances, types etc, whatever
      # registrator rules are stored for property
      class ParameterBagWithRegistrator < ParameterBag
        def initialize(registrator)
          super()
          @registrator = registrator
        end

        def get(name)
          validate_parameter_registration name

          super name
        end

        def set(name, value)
          validate_parameter_registration name

          readonly = @registrator.get_parameter_registration_if_exists(name).readonly?

          if readonly
            value_exists = !get(name).nil?

            if value_exists
              raise "Parameter #{name} is marked readonly! You tried to set it's value, but
              it already has value."
            end
          end

          super name, value
        end

        def validate_parameter_registration(name)
          unless @registrator.parameter_registered? name
            raise "Parameter #{name} was not registered! Did you forget to register that parameter?"
          end
        end
      end
    end
  end
end
