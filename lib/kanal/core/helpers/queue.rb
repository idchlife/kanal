# frozen_string_literal: true

require_relative "../hooks/hook_storage"

module Kanal
  module Core
    module Helpers
      class Queue
        include Hooks

        attr_reader :hooks

        def initialize
          @items = []
          @hooks = HookStorage.new
          hooks.register(:item_queued) # args arguments: item
        end

        def enqueue(element)
          @items.append element
          @hooks.call :item_queued, element
        end

        def dequeue
          @items.shift
        end

        def empty?
          @items.empty?
        end

        def remove(element)
          @items.delete(element)
        end
      end
    end
  end
end
