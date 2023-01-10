# frozen_string_literal: true

require_relative "../../../lib/kanal/core/helpers/parameter_bag_with_registrator"

RSpec.describe Kanal::Core::Helpers::ParameterBagWithRegistrator, Kanal::Core::Helpers::ParameterRegistrator do
  it "stores parameters, forbids storing again for readonly properties" do
    registrator = Kanal::Core::Helpers::ParameterRegistrator.new

    bag = Kanal::Core::Helpers::ParameterBagWithRegistrator.new registrator

    registrator.register_parameter :important_param

    bag.set :important_param, 123

    val = bag.get :important_param

    expect(val).to eq 123

    expect { val = bag.get :non_existent_param }.to raise_error

    bag.set :important_param, 321

    val = bag.get :important_param

    expect(val).to eq 321

    registrator.register_parameter :readonly_param, readonly: true

    bag.set :readonly_param, 444

    val = bag.get :readonly_param

    expect(val).to be 444

    expect { bag.set :readonly_value, 555 }.to raise_error

    val = bag.get :readonly_param

    expect(val).to be 444
  end
end
