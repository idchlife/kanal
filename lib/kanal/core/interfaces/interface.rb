# frozen_string_literal: true

require_relative "../core"

module Kanal
  module Core
    module Interfaces
      # Basic class of interface - interface is basically
      # what is creating inputs and consumes output from the routers
      class Interface
        attr_reader :core

        #
        # Interface makes all neded configuration, plugin registrations,
        # properties registration in the constructor, which requires core.
        # Originally, there was thoughts of interfaces as top level building
        # blocks for ecosystem, this is why interfaces are doing stuff with core
        # inside constructors. It was originally thought that main application
        # file will host like multiple interfaces.
        # This is also why interfaces had no argument core in constructor,
        # because they created cores inside.
        #
        # @param [Kanal::Core::Core] core <description>
        #
        def initialize(core)
          @core = core
        end

        #
        # Returns default router from core
        #
        # @return [Kanal::Core::Router::Router] <description>
        #
        def router
          @core.router
        end

        def modify_core(&block)
          block.call @core
        end

        #
        # Starting the interface, all the needed
        # machinery for it to fire up goes here
        #
        # @return [void] <description>
        #
        def start
          raise NotImplementedError
        end

        #
        # Yet to be discovered how to use this.
        # If method #start executes some synchronous code, how would
        # we stop it from outside? I mean maybe with some kind of flag variable inside?
        #
        # @return [<Type>] <description>
        #
        def stop
          raise NotImplementedError
        end
      end
    end
  end
end
