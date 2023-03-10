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

        def initialize(response_block, input, default_error_node, error_node)
          @response_block = response_block
          @input = input
          @default_error_node = default_error_node
          @error_node = error_node
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
          logger.info "Constructing output for input ##{input.__id__}"

          output = Output::Output.new core.output_parameter_registrator, input, core

          begin
            output.instance_eval(&@response_block.block)

            core.hooks.call :output_before_returned, input, output
          rescue => e
            logger.error "Failed to construct output for input ##{input.__id__}. Error: '#{e}'"

            output = Output::Output.new core.output_parameter_registrator, input, core

            error_node = @error_node || @default_error_node

            logger.info "Trying to construct error response for input ##{input.__id__}. Error response is default: #{@error_node.nil?}"

            begin
              output.instance_eval(&error_node.response_blocks.first.block)

              core.hooks.call :output_before_returned, input, output
            rescue => e
              logger.error "Failed to construct error response for input ##{input.__id__}. Error: '#{e}'"

              logger.info "Trying to construct default error response for input ##{input.__id__}"

              output.instance_eval(&@default_error_node.response_blocks.first.block)

              core.hooks.call :output_before_returned, input, output
            end
          end

          logger.info "Output ##{output.__id__} for input ##{input.__id__} constructed"

          output
        end
      end
    end
  end
end
