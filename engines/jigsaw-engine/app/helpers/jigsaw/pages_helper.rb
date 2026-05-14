module Jigsaw
  module PagesHelper
    def custom_page_path(page)
      "/#{page.path}"
    end
  end
end
