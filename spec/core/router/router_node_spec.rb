# frozen_string_literal: true

require_relative "../../../lib/kanal/core/router/router_node"
require_relative "../../../lib/kanal/core/router/router"
require_relative "../../../lib/kanal/core/core"

RSpec.describe Kanal::Core::Router::RouterNode do
  it "debug_info works" do
    # core = Kanal::Core::Core.new

    # router = Kanal::Core::Router::Router.new :default, core

    # router.configure do
    # end

    router_node = Kanal::Core::Router::RouterNode.new root: true, router: nil, parent: nil

    expect(router_node.debug_info).not_to be nil
  end
end
