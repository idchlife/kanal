# frozen_string_literal: true

require_relative "../../../lib/kanal/core/hooks/hook_storage"

RSpec.describe Kanal::Core::Hooks::HookStorage do
  it "creates hooks, attaches listeners, calls them" do
    hooks = Kanal::Core::Hooks::HookStorage.new

    hooks.register :on_something

    val = nil

    hooks.attach :on_something do |value|
      val = value
    end

    hooks.call :on_something, "testy"

    expect(val).to eq "testy"
  end

  it "calls multiple hooks with unexpected returns without breaking the workflow of code (check for block/proc calls with returns, problem that existen in condition met? block, see more there)" do
    var1 = 0
    var2 = 0
    var3 = 0

    hooks = Kanal::Core::Hooks::HookStorage.new

    hooks.register :on_several

    hooks.attach :on_several do
      var1 = 1

      return false
    end

    hooks.attach :on_several do
      var2 = 1

      return if var1 == 1
    end

    hooks.attach :on_several do
      if true
        var3 = 1

        if false
          return false
        else
          return true
        end
      end
    end

    hooks.call :on_several

    expect(var1).to eq 1
    expect(var2).to eq 1
    expect(var3).to eq 1
  end
end
