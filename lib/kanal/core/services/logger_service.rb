# frozen_string_literal: true

require "logger"

module Kanal
  module Core
    module Services
      class LoggerService
        attr_reader :logger

        def initialize()
          @logger = Logger.new STDOUT
        end

        def info(text)
          @logger.info text
        end

        def debug(text)
          @logger.debug text
        end
      end
    end
  end
end
