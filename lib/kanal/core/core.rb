# frozen_string_literal: true

require_relative "./conditions/condition_storage"
require_relative "./conditions/condition_pack_creator"
require_relative "./router/router_storage"
require_relative "./hooks/hook_storage"
require_relative "./helpers/parameter_registrator"
require_relative "./plugins/plugin"
require_relative "./input/input"
require_relative "./services/service_container"
require_relative "./services/logger_service"

module Kanal
  module Core
    #
    # Main class that end users of Kanal will be using for
    # initialization, plugin registration, conditions registration, etc
    #
    # TODO: consider hiding properties used inside
    # and provide those dependencies explicitly
    # e.g.: output_parameter_registrator is needed for router
    # to create output. It provides the parameters registration
    # info for the Output object. Can it be explicitly passed into the router
    # instead of exposing in in Core?
    #
    # @!attribute [r] hooks
    #   @return [Kanal::Core::Hooks::HookStorage] storage which can be used to register hooks
    # @!attribute [r] services
    #   @return [Kanal::Core::Services::ServiceContainer] service container for registering and getting services
    #
    class Core
      include Conditions
      include Router
      include Helpers
      include Plugins
      include Hooks
      include Services

      # @return [Kanal::Core::Conditions::ConditionStorage]
      attr_reader :condition_storage
      # @return [Kanal::Core::Router::RouterStorage]
      attr_reader :router_storage
      # @return [Kanal::Core::Helpers::ParameterRegistrator]
      attr_reader :input_parameter_registrator
      # @return [Kanal::Core::Helpers::ParameterRegistrator]
      attr_reader :output_parameter_registrator
      # @return [Kanal::Core::Hooks::HookStorage]
      attr_reader :hooks
      # @return [Kanal::Core::Services::ServiceContainer]
      attr_reader :services
      # @return [Kanal::Core::Services::LoggerService.logger]
      attr_reader :logger

      def initialize
        @hooks = HookStorage.new
        register_hooks

        @condition_storage = ConditionStorage.new
        @router_storage = RouterStorage.new self

        @input_parameter_registrator = ParameterRegistrator.new
        @output_parameter_registrator = ParameterRegistrator.new

        @plugins = []

        @services = ServiceContainer.new

        @services.register_service :logger_service, LoggerService, type: :singleton

        @logger = @services.get(:logger_service)
      end

      #
      # Method for registering plugins. Plugins should be of type
      # Kanal::Core::Plugins::Plugin. Meaning that any dervied types
      # would be accepted
      #
      # @param [Kanal::Core::Plugins::Plugin] plugin
      #
      # @return [void]
      #
      def register_plugin(plugin)
        unless plugin.is_a? Plugin
          raise "Plugin must be of type Kanal::Core::Plugin or be a class that inherits base Plugin class"
        end

        begin
          # Checking if name was provided.
          name = plugin.name

          # TODO: _log that plugin already registered with such name
          return if !name.nil? && plugin_registered?(name)

          plugin.setup(self)

          @plugins.append plugin
          # NOTE: Catching here Exception because metho.name can raise ScriptError (derived from Exception)
          # and method .setup can raise ANY type of error.
          # Despite the warnings from linters about "please catch explicitly error or catch StandardError"
          # - sorry, no can't do here
        rescue Exception => e
          name = nil

          begin
            name = plugin.name
          rescue Exception
            name = "CANT_GET_NAME_DUE_TO_ERROR"
          end

          # TODO: _log this info in critical error instead of raising exception
          raise "There was a problem while registering plugin named: #{name}. Error: `#{e}`.
          Remember, plugin errors are often due to .name method not overriden or
          having faulty code inside .setup overriden method"
        end
      end

      #
      # Get registered plugin for modification of some sort
      #
      # @param [Symbol] name <description>
      #
      # @return [<Type>] <description>
      #
      def get_plugin(name)
        @plugins.find { |p| p.name == name }
      end

      #
      # <Description>
      #
      # @param [Symbol] name <description>
      #
      # @return [Boolean] <description>
      #
      def plugin_registered?(name)
        !get_plugin(name).nil?
      end

      #
      # Method creates instance of Kanal::Core::Input::Input
      # Note that right before input returned, hook :input_just_created
      # called
      #
      # @return [Kanal::Core::Input::Input] <description>
      #
      def create_input
        input = Input::Input.new @input_parameter_registrator

        @hooks.call :input_just_created, input

        input
      end

      #
      # Method registers parameters that can be set/get in Kanal::Core::Input::Input
      #
      # @param [Symbol] name <description>
      # @param [Boolean] readonly <description>
      #
      # @return [void] <description>
      #
      def register_input_parameter(name, readonly: false)
        @logger.info "[Core] Registering input parameter: '#{name}', readonly: '#{readonly}'"
        @input_parameter_registrator.register_parameter name, readonly: readonly
      end

      #
      # The same as registering input, but for Kanal::Core::Output::Output
      #
      # @param [Symbol] name <description>
      # @param [Boolean] readonly <description>
      #
      # @return [void] <description>
      #
      def register_output_parameter(name, readonly: false)
        @logger.info "[Core] Registering output parameter: '#{name}', readonly: '#{readonly}'"
        @output_parameter_registrator.register_parameter name, readonly: readonly
      end

      #
      # Handy method with DSL (Domain Specific Language) that allows
      # condition makers to easily create condition packs and
      # conditions.
      #
      # @param [Symbol] name <description>
      # @yield block with inner DSL for adding conditions to condition pack
      #
      # @return [void] <description>
      #
      def add_condition_pack(name, &block)
        @logger.info "[Core] Adding condition pack: '#{name}'"

        creator = ConditionPackCreator.new name

        pack = creator.create(&block)

        @condition_storage.register_condition_pack pack
      end

      #
      # Gets router by the name or if no argument
      # provided, creates and gets :default router
      # This method usually used without arguments,
      # only in special cases you might need to create separate routers
      # TODO: is creating different routers actually needed? Within the same core
      # What cases are possible for such behaviour? Maybe we should remove the ability...
      #
      # @param [Symbol] name <description>
      #
      # @return [Kanal::Core::Router::Router] <description>
      #
      def router(name = :default)
        @router_storage.get_or_create_router name
      end

      def register_hooks
        @hooks.register :input_just_created # input
        @hooks.register :input_before_router # input
        @hooks.register :output_before_returned # input, output
      end

      private :register_hooks
    end
  end
end
