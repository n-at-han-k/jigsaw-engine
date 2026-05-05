module Jigsaw
  class CustomPagesController < ApplicationController
    def show
      path = request.path.delete_prefix(Jigsaw::Engine.routes.find_script_name({}))
      path = path.delete_prefix("/")
      @page = CustomPage.find_by!(path: path)
      @page_modules = @page.page_modules.includes(:data_function, :render_function)
    end
  end
end
