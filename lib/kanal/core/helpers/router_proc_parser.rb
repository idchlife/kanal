require "method_source"

module Kanal
  module Core
    module Helpers
      # Class helps with parsing router procs for
      # helping forming handy DSL without commas
      class RouterProcParser
        def get_conditions_method_names_from_block(&block)
          source = block.source.to_s

          method_names = []

          lines = source.split "\n"

          lines.each do |l|
            names = get_method_names_from_line l

            method_names.concat names
          end

          method_names.uniq
        end

        def get_method_names_from_line(line)
          method_names = []

          line = line.lstrip

          return method_names unless line.start_with? "on"

          words = line.split

          condition_pack = words[1]
          condition = words[2]

          method_names.append condition_pack
          method_names.append condition

          method_names
        end

        private :get_method_names_from_line
      end
    end
  end
end
