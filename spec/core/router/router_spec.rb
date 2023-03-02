# frozen_string_literal: true

require_relative "../../../lib/kanal/core/router/router_node"
require_relative "../../../lib/kanal/core/router/router"
require_relative "../../../lib/kanal/core/core"
require_relative "../../../lib/kanal/core/conditions/condition"
require_relative "../../../lib/kanal/core/conditions/condition_pack"
require_relative "../../../lib/kanal/plugins/batteries/batteries_plugin"

RSpec.describe Kanal::Core::Router::Router do
  it "checks router features with full blown configuration" do
    core = Kanal::Core::Core.new

    # Assuming that kanal-core cannot be well tested without
    # conditions and parameters. Batteries plugin comes out of the box
    # and utilized here
    core.register_plugin Kanal::Plugins::Batteries::BatteriesPlugin.new

    outputs = []

    input = core.create_input

    expect { core.router.consume_input input }.to raise_error(/provide default response for router/)

    core.router.default_response do
      body "Default"
    end

    core.router.configure do
    end

    input = core.create_input

    expect { core.router.consume_input input }.to raise_error(/does not have ANY routes/)

    expect do
      core.router.configure do
        on :body, :starts_with do
        end
      end
    end.to raise_error(/Condition requires argument/)

    core.router.configure do
      on :body, starts_with: "hey" do
        respond do
          body "Welp"
        end
      end

      on :body, starts_with: "never" do
        respond do
          body "keks"
        end
      end

      on :body, contains: "source check" do
        on :source, from: :cli do
          respond do
            body "got message from cli"
          end
        end

        on :source, from: :web do
          respond do
            body "got message from web"
          end
        end
      end

      on :body, starts_with: "at first" do
        on :body, starts_with: "at first there was" do
          respond do
            body "Hey Goobins"
          end
        end

        on :body, starts_with: "at first she was" do
          respond do
            body "second"
          end
        end

        on :body, contains: "ones does" do
          respond do
            body "Third"
          end
        end

        on :flow, :any do
          respond do
            body "Out of the box"
          end
        end
      end
    end

    input = core.create_input

    expect { core.router.consume_input input }.to raise_error(/must provide block via .output_ready/)

    core.router.output_ready do |output|
      outputs << output
    end

    input = core.create_input
    input.body = "hey what's going on"

    outputs = []
    core.router.consume_input input

    expect(outputs.first.body).to include "Welp"

    input = core.create_input
    input.body = "at first there was"

    outputs = []
    core.router.consume_input input

    expect(outputs.first.body).to include "Hey Goobins"

    input = core.create_input
    input.body = "never gonna give you up"

    outputs = []
    core.router.consume_input input

    expect(outputs.first).not_to be nil
    expect(outputs.first.body).to include "keks"

    input = core.create_input
    input.body = "wth"

    outputs = []
    core.router.consume_input input

    expect(outputs.first.body).to include "Default"

    input = core.create_input
    input.body = "at first she was"

    outputs = []
    core.router.consume_input input

    expect(outputs.first.body).to include "second"

    input = core.create_input
    input.body = "at first ones does"

    outputs = []
    core.router.consume_input input

    expect(outputs.first.body).to include "Third"

    # flow any check
    input = core.create_input
    input.body = "at first out of the box"

    outputs = []
    core.router.consume_input input

    expect(outputs.first.body).to include "Out of the box"

    # source check
    input = core.create_input
    input.body = "source check"
    input.source = :cli

    outputs = []
    core.router.consume_input input

    expect(outputs.first.body).to include "got message from cli"

    input = core.create_input
    input.body = "source check"
    input.source = :web

    outputs = []
    core.router.consume_input input

    expect(outputs.first.body).to include "got message from web"
  end

  it "checks multiple-output responses" do
    core = Kanal::Core::Core.new

    core.register_plugin Kanal::Plugins::Batteries::BatteriesPlugin.new

    core.router.configure do
    end

    core.router.default_response do
      body "Default"
    end

    outputs = []

    core.router.output_ready do |output|
      outputs << output
    end

    core.router.configure do
      on :body, starts_with: "multi" do
        respond do
          body "Welp1"
        end

        respond do
          body "Welp2"
        end

        respond do
          body "Welp3"
        end
      end
    end

    input = core.create_input
    input.body = "multi"

    core.router.consume_input input

    expect(outputs.first.body).to include "Welp1"
    expect(outputs.last.body).to include "Welp3"
    expect(outputs.count).to eq 3
  end

  it "checks async responses" do
    core = Kanal::Core::Core.new

    core.register_plugin Kanal::Plugins::Batteries::BatteriesPlugin.new

    core.router.configure do
    end

    core.router.default_response do
      body "Default"
    end

    outputs = []

    core.router.output_ready do |output|
      outputs << output
    end

    core.router.configure do
      on :body, starts_with: "multi" do
        respond do
          body "Welp1"
        end

        respond_async do
          body "Welp2"
        end

        respond do
          body "Welp3"
        end
      end
    end

    input = core.create_input
    input.body = "multi"

    core.router.consume_input input

    expect(outputs.first.body).to include "Welp1"
    expect(outputs.last.body).to include "Welp3"
    expect(outputs.count).to eq 2

    # Waiting for async thread to finish its job
    sleep(0.001)

    expect(outputs.last.body).to include "Welp2"
    expect(outputs.count).to eq 3
  end

  it "checks exception raising without batteries" do
    core = Kanal::Core::Core.new

    core.register_input_parameter :test_condition

    core.add_condition_pack :test_condition do
      add_condition :contains do
        with_argument

        met? do |input, _, argument|
          if input.test_condition.is_a? String
            input.test_condition.include? argument
          else
            false
          end
        end
      end
    end

    core.router.default_response do
      body "Default"
    end

    outputs = []

    core.router.output_ready do |output|
      outputs << output
    end

    core.router.configure do
      on :test_condition, contains: "multi" do
        respond do
          body "Some body"
        end
      end
    end

    input = core.create_input
    input.test_condition = "multi"

    expect { core.router.consume_input input }.to raise_error(/no way to inform end user/)
  end

  it "checks error for respond with batteries" do
    core = Kanal::Core::Core.new

    core.register_plugin Kanal::Plugins::Batteries::BatteriesPlugin.new

    core.router.default_response do
      body "Default"
    end

    outputs = []

    core.router.output_ready do |output|
      outputs << output
    end

    core.router.configure do
      on :body, starts_with: "sync" do
        respond do
          raise "Some error"
        end
      end
    end

    # Default error response body from router
    input = core.create_input
    input.body = "sync"
    core.router.consume_input input
    expect(outputs.first.body).to include "Unfortunately"

    core.router.error_response do
      body "Custom error message"
    end

    # Custom error response provided earlier
    input = core.create_input
    input.body = "sync"
    core.router.consume_input input
    expect(outputs.last.body).to include "Custom error message"
  end

  it "checks error for respond_async with batteries" do
    core = Kanal::Core::Core.new

    core.register_plugin Kanal::Plugins::Batteries::BatteriesPlugin.new

    core.router.default_response do
      body "Default"
    end

    outputs = []

    core.router.output_ready do |output|
      outputs << output
    end

    core.router.configure do
      on :body, starts_with: "async" do
        respond_async do
          raise "Some async error"
        end
      end
    end

    # Default error response body from router

    input = core.create_input
    input.body = "async"
    core.router.consume_input input
    sleep(0.001)
    expect(outputs.first.body).to include "Unfortunately"

    core.router.error_response do
      body "Custom error message"
    end

    # Custom error response provided earlier

    input = core.create_input
    input.body = "async"
    core.router.consume_input input
    sleep(0.001)
    expect(outputs.last.body).to include "Custom error message"
  end

  it "error handling in output_ready_block and error_response" do
  end
end
