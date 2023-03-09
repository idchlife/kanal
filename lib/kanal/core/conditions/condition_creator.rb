# frozen_string_literal: true

require_relative "../logger/logging"

module Kanal
  module Core
    module Conditions
      # This class helps creating conditions in dsl way,
      # with using helper methods
      class ConditionCreator
        include Logging

        def initialize(name)
          @name = name
          @met_block = nil
          @with_argument = false
        end

        def create(&block)
          logger.info "Attempting to create condition '#{@name}'"

          instance_eval(&block)

          unless @name
            logger.fatal "Attempted to create condition without name"

            raise "Please provide name for condition"
          end

          unless @met_block
            logger.fatal "Attempted to create condition without met block"

            raise "Please provide met? block for condition #{@name}"
          end

          logger.info "Creating condition '#{@name}'"

          Condition.new @name, with_argument: @with_argument, &@met_block
        end

        def with_argument
          @with_argument = true
        end

        def met?(&block)
          @met_block = block
        end
      end
    end
  end
end
