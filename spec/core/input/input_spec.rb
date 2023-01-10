# frozen_string_literal: true

require_relative "../../../lib/kanal/core/input/input"
require_relative "../../../lib/kanal/core/helpers/parameter_registrator"

RSpec.describe Kanal::Core::Input::Input do
  it "checks if works properly with setting parameters via dsl" do
    registrator = Kanal::Core::Helpers::ParameterRegistrator.new

    input = Kanal::Core::Input::Input.new registrator

    registrator.register_parameter :body, readonly: true

    input.body = "123"

    body = input.body

    expect(body).to eq "123"

    expect { input.dody = "123" }.to raise_error(/was not registered/)
    expect { input.dody }.to raise_error(/was not registered/)

    expect { input.body = "another value for readonly" }.to raise_error(/readonly/)
  end
end
