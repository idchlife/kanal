# frozen_string_literal: true

require "logger"

module Kanal
  module Core
    module Logging
      # Logger instance will be saved inside class itself for future calls
      @logger_instance

      # Mixing in Logger in some class adds possibility to use logger instance method
      def logger
        @logger_instance ||= Logging.create_logger self.class.name
      end

      class << self
        def create_logger(class_name)
          logger = Logger.new STDOUT
          logger.progname = class_name.rpartition(':').last
          logger.datetime_format = "%d-%m-%Y %H:%M:%S"
          logger
        end
      end
    end
  end
end
