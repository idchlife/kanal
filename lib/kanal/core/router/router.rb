# frozen_string_literal: true

require_relative "./router_node"

module Kanal
  module Core
    module Router
      # Router serves as a container class for
      # root node of router nodes, also as somewhat
      # namespace. Basically class router stores all the
      # router nodes and have a name.
      class Router
        attr_reader :name,
                    :core

        def initialize(name, core)
          @name = name
          @core = core
          @root_node = nil
          @default_node = nil
        end

        def configure(&block)
          # Root node does not have parent
          @root_node ||= RouterNode.new router: self, parent: nil, root: true

          @root_node.instance_eval(&block)
        end

        def default_response(&block)
          raise "default node for router #{@name} already defined" if @default_node

          @default_node = RouterNode.new parent: nil, router: self, default: true

          @default_node.respond(&block)
        end

        # Main method for creating output if it is found or going to default output
        def create_output_for_input(input)
          # Checking if default node with output exists throw error if not
          raise "Please provide default response for router before you try and throw input against it ;)" unless @default_node

          raise "You did not actually .configure router, didn't you? There is no even root node! Use .configure method" unless @root_node

          unless @root_node.children?
            raise "Hey your router actually does not have ANY routes to work with. Did you even try adding them?"
          end

          @core.hooks.call :input_before_router, input

          node = test_input_against_router_node input, @root_node

          # No result means no route node was found for that input
          # using default response
          node ||= @default_node

          output = node.construct_response input

          @core.hooks.call :output_before_returned, input, output

          output
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