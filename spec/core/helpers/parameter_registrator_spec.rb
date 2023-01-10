# frozen_string_literal: true

require_relative "../../../lib/kanal/core/helpers/parameter_registrator"

RSpec.describe Kanal::Core::Helpers::ParameterRegistrator do
  it "registers successfully and stores registered parameters" do
    r = Kanal::Core::Helpers::ParameterRegistrator.new

    registered = r.parameter_registered? :funny

    expect(registered).to eq false

    r.register_parameter :funny

    registered = r.parameter_registered? :funny

    expect(registered).to eq true

    expect { r.register_parameter :funny }.to raise_error

    r.register_parameter :shiny, readonly: true

    registration = r.get_parameter_registration_if_exists :shiny

    expect(registration).not_to be nil

    expect(registration.readonly?).to be true
  end
end
