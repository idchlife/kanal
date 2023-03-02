# frozen_string_literal: true

require_relative "../output/output"

module Kanal
  module Core
    module Helpers
      class ResponseExecutionBlock
        include Output

        attr_reader :response_block, :input

        def initialize(response_block, input, error_node)
          @response_block = response_block
          @input = input
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
          output = Output::Output.new core.output_parameter_registrator, input, core

          begin
            output.instance_eval(&@response_block.block)

            core.hooks.call :output_before_returned, input, output
          rescue => e
            output = Output::Output.new core.output_parameter_registrator, input, core

            begin
              output.instance_eval(&@error_node.response_blocks.first.block)

              core.hooks.call :output_before_returned, input, output
            rescue => e
              if core.plugin_registered? :batteries
                raise "There was an error processing the error_response!"
              else
                raise "There was an error processing the error_response and there is no way to inform end user about it! Please check your provided error_response!"
              end
            end
          end

          output
        end
      end
    end
  end
end
