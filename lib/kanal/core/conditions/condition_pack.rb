# frozen_string_literal: true

require_relative "./condition"
require_relative "./condition_creator"
require_relative "../logger/logging"

module Kanal
  module Core
    module Conditions
      # This class stores conditions inside
      # It is served as some kind of namespace for conditions, with specific
      # name of pack and helper methods
      class ConditionPack
        include Logging

        attr_reader :name

        def initialize(name)
          @name = name
          @conditions = []
        end

        def get_condition_by_name!(name)
          condition = get_condition_by_name name

          unless condition
            logger.warn "Attempted to get condition #{name} in pack #{@name}"

            raise "Condition #{name} was not found in pack #{@name}. Maybe it was not added?"
          end

          condition
        end

        def get_condition_by_name(name)
          @conditions.find { |c| c.name == name }
        end

        def register_condition(condition)
          logger.info "Registering condition '#{condition.name}'"

          unless condition.is_a? Condition
            logger.warn "Attempted to register condition which isn't of Condition class"

            raise "Can register only conditions that inherit Condition class"
          end

          return self if condition_registered? condition

          @conditions.append condition

          self
        end

        def condition_registered?(condition)
          @conditions.each do |c|
            return true if c.name == condition.name
          end

          false
        end

        private :condition_registered?
      end
    end
  end
end
