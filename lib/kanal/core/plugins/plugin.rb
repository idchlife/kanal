# frozen_string_literal: true

require "rake"

module Kanal
  module Core
    module Plugins
      # Base class for plugins that can be registered in the core
      class Plugin
        #
        # Name of the plugin, for it to be available
        # for finding and getting
        #
        # @return [Symbol] <description>
        #
        def name
          raise NotImplementedError
        end

        #
        # This method is for the setting up, it will be executed when plugin
        # is being added to the core
        #
        # @param [Kanal::Core::Core] core <description>
        #
        # @return [void] <description>
        #
        def setup(core)
          raise NotImplementedError
        end

        #
        # If plugins does have rake tasks available for execution,
        # require them here. They will be used
        #
        # @return [Array<Rake::TaskLib>] <description>
        #
        def rake_tasks
          []
        end
      end
    end
  end
end
