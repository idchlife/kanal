# frozen_string_literal: true

require_relative "../../../lib/kanal/core/helpers/parameter_bag"

RSpec.describe Kanal::Core::Helpers::ParameterBag do
  it "stores parameters and gets them" do
    bag = Kanal::Core::Helpers::ParameterBag.new

    bag.set :important_param, 123

    val = bag.get :important_param

    expect(val).to eq 123

    val = bag.get :non_existent_param

    expect(val).to be nil

    bag.set :important_param, 321

    val = bag.get :important_param

    expect(val).to eq 321
  end
end
