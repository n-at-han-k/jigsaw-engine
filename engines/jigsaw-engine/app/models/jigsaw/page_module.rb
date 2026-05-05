module Jigsaw
  class PageModule < ApplicationRecord
    belongs_to :custom_page
    belongs_to :data_function
    belongs_to :render_function
  end
end
