# frozen_string_literal: true

module Kanal
  module Core
    module Services
      # Stores info about service registration
      class ServiceRegistration
        attr_reader :service_class,
                    :type,
                    :block

        def initialize(service_class, type, block)
          @service_class = service_class
          @type = type
          @block = block
        end

        def block?
          !@block.nil?
        end
      end

      #
      # Container allows service registration as well as
      # getting those services. You can register service with different
      # lifespan types.
      #
      class ServiceContainer
        TYPE_SINGLETON = :singleton
        TYPE_TRANSIENT = :transient

        def initialize
          @registrations = {}
          @services = {}
        end

        #
        # Registering service so container knows about it and it's type and it's
        # optional initialization block
        #
        # @param [Symbol] name <description>
        # @param [class] service_class <description>
        # @param [Symbol] type <description>
        # @yield Initialization block. It should be used if your service
        #   requires postponed initialization
        #
        # @return [void] <description>
        #
        def register_service(name, service_class, type: TYPE_SINGLETON, &block)
          return if @registrations.key? name

          raise "Unrecognized service type #{type}. Allowed types: #{allowed_types}" unless allowed_types.include? type

          registration = ServiceRegistration.new service_class, type, block

          @registrations[name] = registration
        end

        #
        # Gets the registered service by name
        #
        # @param [Symbol] name <description>
        #
        # @return [Object] <description>
        #
        def get(name)
          raise "Service named #{name} was not registered in container" unless @registrations.key? name

          registration = @registrations[name]

          case registration.type
          when TYPE_SINGLETON
            # Created once and reused after creation
            @services[name] = create_service_from_registration registration if @services[name].nil?

            @services[name]
          when TYPE_TRANSIENT
            # Created every time
            create_service_from_registration registration
          end
        end

        def create_service_from_registration(registration)
          return registration.block.call if registration.block?

          registration.service_class.new
        end

        def allowed_types
          [TYPE_SINGLETON, TYPE_TRANSIENT]
        end

        private :create_service_from_registration,
                :allowed_types
      end
    end
  end
end
