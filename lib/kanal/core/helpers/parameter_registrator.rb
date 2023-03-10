# frozen_string_literal: true

require_relative "../logger/logging"

module Kanal
  module Core
    module Helpers
      # For registered property info,
      # this class is used for future additions,
      # maybe type validations or something
      class ParameterRegistration
        def initialize(readonly)
          @readonly = readonly
        end

        def readonly?
          @readonly
        end
      end

      # Class holds parameter names that are allowed
      # to be used.
      class ParameterRegistrator
        include Logging

        def initialize
          @parameters_by_name = {}
        end

        # readonly paramaeter means that once it was initialized - it cannot
        # be changed. handy for input parameters populated by interface or
        # whatever
        def register_parameter(name, readonly: false)
          if @parameters_by_name.key? name
            logger.fatal "Attempted to register already registered parameter '#{name}'"

            raise "Parameter named #{name} already registered!"
          end

          logger.info "Registering parameter '#{name}'"

          registration = ParameterRegistration.new readonly

          @parameters_by_name[name] = registration
        end

        # returns nil if no parameter registered
        def get_parameter_registration_if_exists(name)
          return nil unless @parameters_by_name.key? name

          @parameters_by_name[name]
        end

        def parameter_registered?(name)
          !get_parameter_registration_if_exists(name).nil?
        end
      end
    end
  end
end
