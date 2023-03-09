# frozen_string_literal: true

require_relative "../logger/logging"

module Kanal
  module Core
    module Conditions
      # Base class for conditions
      # with this class you can
      class Condition
        include Logging

        attr_reader :name

        def initialize(name, with_argument: false, &met_block)
          @name = name

          unless met_block
            logger.warn "Attempt create condition #{name} without block"
            raise "Cannot create condition without block"
          end

          @with_argument = with_argument

          # NOTE: this whole bunch of code, including method, is used to allow
          # in blocks returns without LocalJumpError
          # Basically converting block/proc into lambda, which will allow
          # unexpected returns for the comfortability of writing conditions
          # Kudos to: https://stackoverflow.com/a/2946734/2739103
          @proc_to_lambda_object = Object.new
          @proc_to_lambda_object.define_singleton_method(:met_block, &met_block)
        end

        def with_argument?
          @with_argument
        end

        # Check constructor for more info about this weird met block call
        def met?(input, core, argument)
          @proc_to_lambda_object.method(:met_block).call input, core, argument
        end
      end
    end
  end
end
