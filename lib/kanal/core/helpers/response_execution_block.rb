# frozen_string_literal: true

require_relative "../output/output"
require_relative "../logger/logging"

module Kanal
  module Core
    module Helpers
      class ResponseExecutionBlock
        include Output
        include Logging

        attr_reader :response_block, :input

        def initialize(response_block, input)
          @response_block = response_block
          @input = input
        end

        def execute(core, output_queue)
          if response_block.async?
            # NOTE: Thread doesnt just die here - it's execution is continued in output_queue.enqueue in router
            # then :item_queued hook is called inside and subsequently output_ready_block gets called in this thread
            # TODO: be aware that this can cause unexpected behaviour. Maybe think how to rework it.
            Thread.new do
              output_queue.enqueue construct_output(core)
            end
          else
            output_queue.enqueue construct_output(core)
          end
        end

        private

        def construct_output(core)
          logger.debug "Constructing output for input ##{input.__id__}"

          output = Output::Output.new core.output_parameter_registrator, input, core

          output.instance_eval(&@response_block.block)

          core.hooks.call :output_before_returned, input, output

          logger.debug "Output ##{output.__id__} for input ##{input.__id__} constructed"

          output
        end
      end
    end
  end
end
