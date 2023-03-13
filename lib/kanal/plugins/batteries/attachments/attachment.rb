# frozen_string_literal: true

module Kanal
  module Plugins
    module Batteries
      module Attachments
        class Attachment
          attr_reader :url, :dir_path

          def initialize(url)
            @url = url
            # TODO: Create directory / check if directory exists
            @dir_path = "./uploads/#{self.class.name}/"
          end

          def save()
            # downloads @url content
            # generates filename, checks if file exists, recursively
            # saves file
            # TODO: file extensions depending on self.class.name?
            # returns filepath
          end
        end
      end
    end
  end
end
