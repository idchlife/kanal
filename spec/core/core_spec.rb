# frozen_string_literal: true

require_relative "../../lib/kanal/core/core"
require_relative "../../lib/kanal/core/plugins/plugin"

class TestPlugin < Kanal::Core::Plugins::Plugin
  def name
    :test
  end

  def setup(core)
    core.register_input_parameter :test
  end
end

class NamelessPlugin < Kanal::Core::Plugins::Plugin
  def setup(core)
    # do something
  end
end

class FaultyPlugin < Kanal::Core::Plugins::Plugin
  def name
    :faulty
  end

  def setup(core)
    raise "I'm broken please fix me though dev
    probably abandoned me long time ago... Your dev is in another castle mate"
  end
end

RSpec.describe Kanal::Core::Core do
  it "checks plugin registration and it's errors, also getting registered plugins" do
    core = Kanal::Core::Core.new

    pseudo_plugin = "something else"

    expect { core.register_plugin pseudo_plugin }.to raise_error(/Plugin must be of type/)

    plugin = TestPlugin.new

    core.register_plugin plugin

    expect(core.input_parameter_registrator.parameter_registered?(:test)).to eq true

    registered_plugin = core.get_plugin :test

    expect(registered_plugin).to be_instance_of TestPlugin

    expect { core.register_plugin NamelessPlugin.new }.to raise_error(/NotImplementedError/)

    expect { core.register_plugin FaultyPlugin.new }.to raise_error(/I'm broken please fix me/)

    expect(core.plugin_registered?(:test)).to eq true
  end
end
