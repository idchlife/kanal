# frozen_string_literal: true

require_relative "../../../lib/kanal/core/services/service_container"

class SimpleService
  attr_accessor :value

  def initialize
    @value = nil
  end
end

class SimpleServiceWithArgument
  attr_reader :value

  def initialize(value)
    @value = value
  end
end

RSpec.describe Kanal::Core::Services::ServiceContainer do
  it "all the service container workflow" do
    container = Kanal::Core::Services::ServiceContainer.new

    container.register_service :simple_singleton, SimpleService, type: :singleton

    service = container.get :simple_singleton

    expect(service).to be_a SimpleService

    service.value = 123

    service = container.get :simple_singleton

    expect(service.value).to eq 123

    container.register_service :simple_transient, SimpleService, type: :transient

    service = container.get :simple_transient

    service.value = 456

    service = container.get :simple_transient

    expect(service.value).to be nil

    expect { container.get :something }.to raise_error(/was not registered/)
  end

  it "registers service with block and expects block to be used instead of class" do
    container = Kanal::Core::Services::ServiceContainer.new

    container.register_service :with_argument, SimpleServiceWithArgument do
      SimpleServiceWithArgument.new "got here"
    end

    service = container.get :with_argument

    expect(service.value).to eq "got here"
  end
end
