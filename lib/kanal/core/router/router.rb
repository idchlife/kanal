# frozen_string_literal: true

require_relative "./router_node"
require_relative "../helpers/queue"
require_relative "../helpers/response_execution_block"

module Kanal
  module Core
    module Router
      # Router serves as a container class for
      # root node of router nodes, also as somewhat
      # namespace. Basically class router stores all the
      # router nodes and have a name.
      class Router
        include Helpers

        attr_reader :name, :core, :output_ready_block

        def initialize(name, core)
          core.logger.info "[Router] Initializing"
          @name = name
          @core = core
          @root_node = nil
          @default_node = nil
          @response_execution_queue = Queue.new
          @output_queue = Queue.new
          @output_ready_block = nil
          @core.hooks.register(:output_ready) # arg

          _this = self
          _output_queue = @output_queue
          @output_queue.hooks.attach :item_queued do |output|
            _this.core.logger.debug "[Router] Calling output_ready block for input ##{output.input.__id__} and output #{output.__id__}. Output body is: '#{output.body}'"
            _this.output_ready_block.call output
            _output_queue.remove(output)
          end
        end

        def configure(&block)
          @core.logger.info "[Router] Configuring"
          # Root node does not have parent
          @root_node ||= RouterNode.new router: self, parent: nil, root: true

          @root_node.instance_eval(&block)
        end

        def default_response(&block)
          @core.logger.info "[Router] Setting default response"

          raise "default node for router #{@name} already defined" if @default_node

          @default_node = RouterNode.new parent: nil, router: self, default: true

          @default_node.respond(&block)
        end

        # Main method for creating output(s) if it is found or going to default output
        def consume_input(input)
          @core.logger.info "[Router] Consuming input #{input.__id__}. Body: '#{input.body}'"

          # Checking if default node with output exists throw error if not
          unless @default_node
            raise "Please provide default response for router before you try and throw input against it ;)"
          end

          unless @root_node
            raise "You did not actually .configure router, didn't you? There is no even root node! Use .configure method"
          end

          unless @root_node.children?
            raise "Hey your router actually does not have ANY routes to work with. Did you even try adding them?"
          end

          unless @output_ready_block
            raise "You must provide block via .output_ready for router to function properly"
          end

          @core.hooks.call :input_before_router, input

          node = test_input_against_router_node input, @root_node

          # No result means no route node was found for that input
          # using default response
          node ||= @default_node

          response_blocks = node.response_blocks

          response_execution_blocks = response_blocks.map { |rb| ResponseExecutionBlock.new rb, input }

          response_execution_blocks.each do |reb|
            @response_execution_queue.enqueue reb
          end

          process_response_execution_queue
        end

        def process_response_execution_queue
          until @response_execution_queue.empty?
            response_execution = @response_execution_queue.dequeue

            response_execution.execute core, @output_queue
          end
        end

        def output_ready(&block)
          core.logger.debug "[Router] Setting output_ready block"
          @output_ready_block = block
        end

        # Recursive method for searching router nodes
        def test_input_against_router_node(input, router_node)
          # Allow root node because it does not have any conditions and does not have
          # any responses, but it does have children. Well, it should have children...
          # Basically:
          # if router_node is root - proceed with code
          # if router_node is not root and condition is not met - stop right here.
          # Cannot proceed inside of this node.
          return if !router_node.root? && !router_node.condition_met?(input, @core)

          # Check if node has children first. Router node with children SHOULD NOT HAVE RESPONSE.
          # There is an exception for this case so don't worry, it's not protected only by
          # this comment
          if router_node.children?
            node = nil

            router_node.children.each do |c|
              node = test_input_against_router_node input, c

              break if node
            end

            node
          elsif router_node.response?
            # Router node without children can have response
            router_node
          end
        end

        private :test_input_against_router_node
      end
    end
  end
end
