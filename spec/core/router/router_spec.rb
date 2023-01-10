# frozen_string_literal: true

require_relative "../../../lib/kanal/core/router/router_node"
require_relative "../../../lib/kanal/core/router/router"
require_relative "../../../lib/kanal/core/core"
require_relative "../../../lib/kanal/core/conditions/condition"
require_relative "../../../lib/kanal/core/conditions/condition_pack"
require_relative "../../../lib/kanal/plugins/batteries/batteries_plugin.rb"

RSpec.describe Kanal::Core::Router::Router do
  it "checks router features with full blown configuration" do
    core = Kanal::Core::Core.new

    # Assuming that kanal-core cannot be well tested without
    # conditions and parameters. Batteries plugin comes out of the box
    # and utilized here
    core.register_plugin Kanal::Plugins::Batteries::BatteriesPlugin.new

    core.router.configure do
    end

    core.router.default_response do
      body "Default"
    end

    input = core.create_input

    expect { core.router.create_output_for_input input }.to raise_error(/does not have ANY routes/)

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
    input.body = "hey what's going on"

    output = core.router.create_output_for_input input

    expect(output.body).to include "Welp"

    input = core.create_input
    input.body = "at first there was"

    output = core.router.create_output_for_input input

    expect(output.body).to include "Hey Goobins"

    input = core.create_input
    input.body = "never gonna give you up"

    output = core.router.create_output_for_input input

    expect(output).not_to be nil
    expect(output.body).to include "keks"

    input = core.create_input
    input.body = "wth"

    output = core.router.create_output_for_input input

    expect(output.body).to include "Default"

    input = core.create_input
    input.body = "at first she was"

    output = core.router.create_output_for_input input

    expect(output.body).to include "second"

    input = core.create_input
    input.body = "at first ones does"

    output = core.router.create_output_for_input input

    expect(output.body).to include "Third"

    # flow any check
    input = core.create_input
    input.body = "at first out of the box"

    output = core.router.create_output_for_input input

    expect(output.body).to include "Out of the box"

    # source check
    input = core.create_input
    input.body = "source check"
    input.source = :cli

    output = core.router.create_output_for_input input

    expect(output.body).to include "got message from cli"

    input = core.create_input
    input.body = "source check"
    input.source = :web

    output = core.router.create_output_for_input input

    expect(output.body).to include "got message from web"
  end
end
