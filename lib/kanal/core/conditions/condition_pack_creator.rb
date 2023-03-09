# frozen_string_literal: true

require_relative "./condition_pack"
require_relative "./condition_creator"
require_relative "../logger/logging"

module Kanal
  module Core
    module Conditions
      # This class helps in condition pack creation
      # with the help of dsl
      class ConditionPackCreator
        include Logging

        TEMP_NAME = :temp_name

        def initialize(name)
          @name = name
          @conditions = []
        end

        def create(&block)
          instance_eval(&block)

          unless @name
            logger.warn "Attempted to create condition pack without name"

            raise "Please provide condition pack name"
          end

          if @conditions.empty?
            logger.warn "Attempted to create condition pack #{@name} without conditions provided"

            raise "Please provide conditions for condition pack #{@name}"
          end

          logger.info "Creating condition pack '#{@name}'"

          pack = ConditionPack.new(@name)

          @conditions.each do |c|
            pack.register_condition c
          end

          pack
        end

        def add_condition(name, &block)
          creator = ConditionCreator.new name
          condition = creator.create(&block)
          @conditions.append condition
        end
      end
    end
  end
end
