# frozen_string_literal: true

module Kanal
  module Core
    module Hooks
      #
      # Allows hooks registration,
      # attaching to hooks, calling hooks with arguments
      #
      class HookStorage
        def initialize
          @listeners = {}
        end

        #
        # Registers hook in storage. All you need is name
        #
        # @example Registering a hook
        #   hook_storage.register(:my_hook) # That is all
        #
        # @param [Symbol] name <description>
        #
        # @return [void] <description>
        #
        # TODO: think about requiring optional string about hook arguments?
        # like register(:my_hook, "name, last_name")
        # or is it too weird and unneeded? I mean besides the documentation
        # there is no way to learn which arguments are used in specific hook.
        # Wondrous world of dynamic languages 🌈🦄
        #
        def register(name)
          return if hook_exists? name

          @listeners[name] = []
        end

        #
        # Calling hook with any arguments you want.
        # Well, when you registered hooks you basically had in mind
        # which arguments should be used when calling them
        #
        # @example Calling hook with arguments
        #   # Considering names variables (old_name, new_name) are available when calling a hook
        #   # This one will call the :name_changed hook with passed arguments.
        #   # What does that mean? That possibly there is a listener attached to this hook
        #   # @see #attach for next step of this example
        #   hook_storage.call :name_changed, old_name, new_name
        #
        # @param [Symbol] name <description>
        # @param [Array] args <description>
        #
        # @return [void] <description>
        #
        def call(name, *args)
          raise "Cannot call hook that is not registered: #{name}" unless hook_exists? name

          @listeners[name].each do |l|
            l.method(:hook_block).call(*args)
          end
        rescue RuntimeError => e
          raise "There was a problem with calling hooks #{name}. Args: #{args}. More info: #{e}"
        end

        #
        # Attaches block to a specific hook.
        # You can learn about available hooks by
        # looking into documentation of the specific libraries,
        # using this class.
        #
        # @example Attaching to name changing hook, the next step after @see #call example
        #   hook_storage.attach :name_changed do |old_name, new_name|
        #     # Here you do something with the provided arguments
        #   end
        #
        # NOTE: about weird saving objects with methods instead of blocks
        # see more info in Condition class, you will learn why (hint: LocalJumpError)
        #
        # @param [Symbol] name <description>
        # @yield block that will be executed upon calling hook it was registered to
        #
        # @return [void] <description>
        #
        def attach(name, &block)
          raise "You cannot listen to hook that does not exist! Hook in question: #{name}" unless hook_exists? name

          proc_to_lambda_object = Object.new
          proc_to_lambda_object.define_singleton_method(:hook_block, &block)

          @listeners[name].append proc_to_lambda_object
        end

        #
        # Self explanatory name of method
        #
        # @param [Symbol] name <description>
        #
        # @return [Boolean] <description>
        #
        def hook_exists?(name)
          !@listeners[name].nil?
        end

        private :hook_exists?
      end
    end
  end
end
