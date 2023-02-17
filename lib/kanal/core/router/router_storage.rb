# frozen_string_literal: true

require_relative "./router"

module Kanal
  module Core
    module Router
      # Class with helper methods for creating and getting routers
      class RouterStorage
        def initialize(core)
          @routers = []
          @core = core
        end

        #
        # Creates router by name and stores it for further access
        #
        # @param [Symbol] name <description>
        #
        # @return [Kanal::Core::Router::Router] <description>
        #
        def get_or_create_router(name)
          router = @routers.find { |r| r.name == name }

          unless router
            router = Router.new name, @core
            @routers.append router
          end

          router
        end
      end
    end
  end
end
