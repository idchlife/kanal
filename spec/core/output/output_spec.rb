# frozen_string_literal: true

require_relative "../../../lib/kanal/core/output/output"
require_relative "../../../lib/kanal/core/input/input"
require_relative "../../../lib/kanal/core/helpers/parameter_registrator"

RSpec.describe Kanal::Core::Output::Output do
  it "used with dsl with properties and stuff" do
    input_registrator = Kanal::Core::Helpers::ParameterRegistrator.new
    input_registrator.register_parameter :body, readonly: true

    input = Kanal::Core::Input::Input.new input_registrator

    registrator = Kanal::Core::Helpers::ParameterRegistrator.new

    output = Kanal::Core::Output::Output.new registrator, input, nil

    registrator.register_parameter :body

    output.configure_dsl do
      body "kek"
    end

    expect(output.body).to eq "kek"

    expect { output.dody }.to raise_error(/was not registered/)

    expect(output.input).to eq input
  end
end
