module Jigsaw
  module CustomModuleHelper
    def CustomModule(**kwargs, &block)
      output_buffer << render(CustomModuleComponent.new(**kwargs), &block)
    end
  end
end
