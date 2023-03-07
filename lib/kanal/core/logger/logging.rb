# frozen_string_literal: true

require "logger"

module Kanal
  module Core
    module Logging
      # Logger instance will be saved inside class itself for future calls
      @logger_instance

      # Mixing in Logger in some class adds possibility to use logger instance method
      def logger
        @logger_instance = Logging.create_logger self.class.name
      end

      class << self
        def get_or_create_logger(class_name)
          @logger_instance ||= create_logger(class_name)
        end

        def create_logger(class_name)
          logger = Logger.new STDOUT
          logger.progname = class_name.rpartition(':').last
          logger
        end
      end
    end
  end
end
