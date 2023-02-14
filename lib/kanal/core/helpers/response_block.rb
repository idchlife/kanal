module Kanal
  module Core
    module Helpers
      class ResponseBlock
        attr_reader :block
        def initialize(block, async: false)
          @block = block
          @async = async
        end
        def async?
          @async
        end
      end
    end
  end
end
