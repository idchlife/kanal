# frozen_string_literal: true

require_relative "../../../lib/kanal/core/input/input"
require_relative "../../../lib/kanal/core/conditions/condition"
require_relative "../../../lib/kanal/core/helpers/parameter_registrator"

RSpec.describe Kanal::Core::Conditions::Condition do
  it "check if condition really works with provided block and used with method met?" do
    registrator = Kanal::Core::Helpers::ParameterRegistrator.new

    input = Kanal::Core::Input::Input.new registrator

    registrator.register_parameter :body

    input.body = "never gonna give you up"

    condition = Kanal::Core::Conditions::Condition.new :body_starts_with do |inp, _, argument|
      inp.body.start_with? argument
    end

    expect(condition.met?(input, nil, "hey")).to eq false
    expect(condition.met?(input, nil, "never")).to eq true
  end

  it "checks if met block in condition works without LocalJumpError with sudden returns (problem was before block for met? was not wrapped" do
    registrator = Kanal::Core::Helpers::ParameterRegistrator.new

    input = Kanal::Core::Input::Input.new registrator

    registrator.register_parameter :body

    input.body = "never gonna give you up"

    condition = Kanal::Core::Conditions::Condition.new :body_starts_with do |inp, _, argument|
      if input.body.include? "whatever"
        return false if true
      else
        return false
      end

      inp.body.start_with? argument
    end

    expect(condition.met?(input, nil, "whatever")).to eq false
    expect(condition.met?(input, nil, "random stuff")).to eq false
  end
end
