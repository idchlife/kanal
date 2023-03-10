# frozen_string_literal: true

require_relative "../logger/logging"

module Kanal
  module Core
    module Conditions
      # This class contains all needed functionality to store,
      # search conditions
      class ConditionStorage
        include Logging

        def initialize
          @condition_packs = []
        end

        def get_condition_pack_by_name!(name)
          pack = get_condition_pack_by_name name

          unless pack
            logger.fatal "Attempted to request unregistered condition pack #{name} from ConditionStorage"

            raise "Condition pack #{name} is not registered, but was requested from ConditionStorage"
          end

          pack
        end

        def get_condition_pack_by_name(name)
          @condition_packs.find { |p| p.name == name }
        end

        def condition_pack_or_condition_exists?(name)
          pack = get_condition_pack_by_name name

          unless pack
            found_condition = false
            # Checking every pack for conditions inside of it
            @condition_packs.each do |cp|
              condition = cp.get_condition_by_name name

              if condition
                found_condition = true
                break
              end
            end

            return found_condition
          end

          !pack.nil?
        end

        def register_condition_pack(pack)
          return if condition_pack_exists? pack

          unless pack.is_a? ConditionPack
            logger.fatal "Attempted to register condition pack which isn't of ConditionPack class"

            raise "Condition pack should be descendant of ConditionPack class"
          end

          logger.info "Registering condition pack '#{pack.name}'"

          @condition_packs.append pack
        end

        def condition_pack_exists?(pack)
          !(@condition_packs.find { |cp| cp.name == pack.name }).nil?
        end
      end
    end
  end
end
