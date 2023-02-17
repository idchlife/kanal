# frozen_string_literal: true

module Kanal
  module Core
    module Helpers
      module ConditionFinder
        class ConditionFindResult
          attr_reader :found_condition_pack,
                      :found_condition

          def initialize(found_condition_pack: false, found_condition: false)
            @found_condition_pack = found_condition_pack
            @found_condition = found_condition
          end

          def found_anything?
            @found_condition || @found_condition_pack
          end
        end

        class ConditionFinder
          def find_by_name(name); end
        end
      end
    end
  end
end
