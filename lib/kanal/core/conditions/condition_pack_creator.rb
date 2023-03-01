# frozen_string_literal: true

require_relative "./condition_pack"
require_relative "./condition_creator"

module Kanal
  module Core
    module Conditions
      # This class helps in condition pack creation
      # with the help of dsl
      class ConditionPackCreator
        TEMP_NAME = :temp_name

        def initialize(name)
          @name = name
          @conditions = []
        end

        def create(&block)
          instance_eval(&block)

          raise "Please provide condition pack name" unless @name

          raise "Please provide conditions for condition pack #{@name}" if @conditions.empty?

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
