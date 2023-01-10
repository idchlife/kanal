require_relative "./condition"
require_relative "./condition_creator"

module Kanal
  module Core
    module Conditions
      # This class stores conditions inside
      # It is served as some kind of namespace for conditions, with specific
      # name of pack and helper methods
      class ConditionPack
        attr_reader :name

        def initialize(name)
          @name = name
          @conditions = []
        end

        def get_condition_by_name!(name)
          condition = get_condition_by_name name

          raise "Condition #{name} was not found in pack #{@name}. Maybe it was not added?" unless condition

          condition
        end

        def get_condition_by_name(name)
          @conditions.find { |c| c.name == name }
        end

        def register_condition(condition)
          raise "Can register only conditions that inherit Condition class" unless condition.is_a? Condition

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
