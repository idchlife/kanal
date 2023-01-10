module Kanal
  module Core
    module Conditions
      # This class helps creating conditions in dsl way,
      # with using helper methods
      class ConditionCreator
        def initialize(name)
          @name = name
          @met_block = nil
          @with_argument = false
        end

        def create(&block)
          instance_eval(&block)

          raise "Please provide name for condition" unless @name
          raise "Please provide met? block for condition #{@name}" unless @met_block

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
