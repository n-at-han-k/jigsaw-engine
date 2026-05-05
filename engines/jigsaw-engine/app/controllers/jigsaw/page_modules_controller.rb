module Jigsaw
  class PageModulesController < ApplicationController
    def edit
      @page_module = PageModule.includes(:data_function, :render_function).find(params[:id])
    end
  end
end
