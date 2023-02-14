require_relative "../output/output"

module Kanal
  module Core
    module Helpers
      class ResponseExecutionBlock
        include Output

        attr_reader :response_block, :input
        def initialize(response_block, input)
          @response_block = response_block
          @input = input
        end
        def execute(core, output_queue)
          if response_block.async?
            Thread.new do
              output_queue.enqueue construct_output(core)
            end
          else
            output_queue.enqueue construct_output(core)
          end
        end

        private

        def construct_output(core)
          output = Output::Output.new core.output_parameter_registrator, input, core

          output.instance_eval(&@response_block.block)

          output
        end
      end
    end
  end
end
