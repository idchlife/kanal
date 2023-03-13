# frozen_string_literal: true

require_relative "../../../core/helpers/file_creator"

module Kanal
  module Plugins
    module Batteries
      module Attachments
        class Attachment
          include Core::Helpers::FileCreator

          def initialize(url)
            @url = url
          end

          def save(dir_path, extension)
            # TODO: add code here
            content = "downloaded url content"

            filepath = save_file_and_get_path content, dir_path, extension

            filepath
          end
        end
      end
    end
  end
end
