# frozen_string_literal: true

require_relative "../../core/interfaces/interface"
require_relative "../../plugins/batteries/batteries_plugin"

module Kanal
  module Interfaces
    module SimpleCli
      # This interface provides input/output with the cli
      class SimpleCliInterface < Kanal::Core::Interfaces::Interface
        #
        # <Description>
        #
        # @param [Kanal::Core::Core] core <description>
        #
        def initialize(core)
          super

          # For simple cli we need body
          @core.register_plugin Kanal::Plugins::Batteries::BatteriesPlugin.new

          @core.register_output_parameter :quit
        end

        def start
          loop do
            puts ">>>"
            input = @core.create_input
            input.body = gets

            output = router.create_output_for_input input

            if output.quit
              puts "Undestood! Quitting"
              break
            end

            puts "[bot]: #{output.body}"
          rescue Interrupt
            puts "Got it! Hard stop. Bye bye!"
            break
          end

          puts "End of conversation!"
        end

        def stop; end
      end
    end
  end
end
