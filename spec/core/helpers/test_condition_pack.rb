# frozen_string_literal: true

require_relative "../../../lib/kanal/core/conditions/condition_pack"

include Kanal::Core::Conditions

class InputPropertyCondition < Condition
  def met?(input, *args); end
end

test_condition_pack = ConditionPack.new :test

test_condition_pack.add InputPropertyCondition.new :input_property
