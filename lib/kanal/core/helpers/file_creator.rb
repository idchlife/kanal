# frozen_string_literal: true

require 'fileutils'

module Kanal
  module Core
    module Helpers
      module FileCreator
        def save_file_and_get_path(content, directory, extension, length = 32)
          create_directory(directory) unless File.directory?(directory)

          filename = generate_filename extension, length

          filepath = directory + filename

          save_file_with_random_name content, directory, extension, length if File.exist? filepath

          File.write(filepath, content)

          filepath
        end

        def generate_filename(extension, length)
          alphanumeric = "abcdefghijkmnopQRSTUVWNXYZW12345676789-".chars

          name = ""

          extension = extension.gsub(".", "") if extension.include?(".")

          length.times do
            name += alphanumeric.sample
          end

          "#{name}.#{extension}"
        end

        def create_directory(dir)
          FileUtils.mkdir_p dir
        end
      end
    end
  end
end
