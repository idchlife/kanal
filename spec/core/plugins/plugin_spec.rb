# frozen_string_literal: true

require_relative "../../../lib/kanal/core/plugins/plugin"

class IncompletePlugin < Kanal::Core::Plugins::Plugin
end

RSpec.describe Kanal::Core::Plugins::Plugin do
  it "covers plugin errors and features" do
    plugin = Kanal::Core::Plugins::Plugin.new

    expect { plugin.setup nil }.to raise_error(NotImplementedError)
  end
end
