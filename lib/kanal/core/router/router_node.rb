# frozen_string_literal: true

require_relative "../output/output"
require_relative "../helpers/response_block"

module Kanal
  module Core
    # This module stores RouterNode and helper classes which are
    # important for building router nodes tree
    module Router
      # This class is used as a node in router
      # tree, containing conditions and responses
      class RouterNode
        include Output
        include Helpers

        attr_reader :parent,
                    :children

        # parameter default: is for knowing that this node
        # is for default response
        # default response cannot have child nodes
        def initialize(*args, router:, parent:, default: false, root: false, error: false)
          @router = router
          @parent = parent

          @children = []

          @response_blocks = []

          @condition_pack_name = nil
          @condition_name = nil
          @condition_argument = nil

          # We omit setting conditions because default router node does not need any conditions
          # Also root node does not have conditions so we basically omit them if arguments are empty
          return if default || root || error

          # With this we attach names of condition pack and condition to this router
          # node, so we will be able to find them later at runtime and use them
          assign_condition_pack_and_condition_names_from_args!(*args)
        end

        def on(*args, &block)
          raise "You cannot add children to nodes with response ready. Response is a final line" if response?

          child = RouterNode.new(*args, router: @router, parent: self)
          add_child child

          child.instance_eval(&block)
        end

        def response_blocks
          if @response_blocks.empty?
            raise "no response block configured for this node. router: #{@router.name}. debug: #{debug_info}"
          end

          @response_blocks
        end

        def respond(&block)
          raise "Router node with children cannot have response" unless @children.empty?

          @response_blocks.append ResponseBlock.new(block)
        end

        def respond_async(&block)
          raise "Router node with children cannot have response" unless @children.empty?

          @response_blocks.append ResponseBlock.new(block, async: true)
        end

        def response?
          !@response_blocks.empty?
        end

        # This method processes args to populate condition and condition pack
        # in this router node
        def assign_condition_pack_and_condition_names_from_args!(*args)
          condition_pack_name = args[0]
          condition_name = args[1]

          # We assume we got condition that requires argument
          if condition_name.is_a? Hash
            # We search for arguments inside kwargs
            @condition_argument = condition_name.values.first

            condition_name = condition_name.keys.first
          end

          # This calls will raise errors if there is problem with pack or condition
          # inside of it
          pack = @router.core.condition_storage.get_condition_pack_by_name! condition_pack_name
          condition = pack.get_condition_by_name! condition_name

          if condition.with_argument? && !@condition_argument
            raise "Condition requires argument, though you wrote it as :symbol, not as positional_arg:
            Please check route with condition pack: #{condition_pack_name} and condition: #{condition_name}"
          end

          @condition_pack_name = condition_pack_name
          @condition_name = condition_name
        end

        def debug_info
          "RouterNode with condition pack: #{@condition_pack_name}, condition: #{@condition_name}, condition argument: #{@condition_argument}"
        end

        def condition_met?(input, core)
          c = condition

          c.met? input, core, @condition_argument
        end

        def condition
          pack = @router.core.condition_storage.get_condition_pack_by_name! @condition_pack_name

          pack.get_condition_by_name! @condition_name
        end

        def root?
          parent.nil?
        end

        def children?
          !@children.empty?
        end

        def add_child(node)
          @children.append node
        end

        private :add_child
      end
    end
  end
end
