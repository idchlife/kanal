# frozen_string_literal: true

require_relative "../../../lib/kanal/core/conditions/condition_storage"
require_relative "../../../lib/kanal/core/conditions/condition"
require_relative "../../../lib/kanal/core/conditions/condition_pack"

RSpec.describe Kanal::Core::Conditions::ConditionStorage do
  it "checks storage condition registration, condition finding etc" do
    pack = Kanal::Core::Conditions::ConditionPack.new :test

    condition = Kanal::Core::Conditions::Condition.new :works do |input, core, argument|
      true
    end

    pack.register_condition condition

    storage = Kanal::Core::Conditions::ConditionStorage.new

    storage.register_condition_pack pack

    expect(storage.get_condition_pack_by_name(:test)).not_to be nil

    expect(storage.condition_pack_or_condition_exists?(:test)).to be true
    expect(storage.condition_pack_or_condition_exists?(:works)).to be true

    expect(storage.condition_pack_or_condition_exists?(:random)).to be false
  end
end
