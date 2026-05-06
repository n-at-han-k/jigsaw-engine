module Jigsaw
  class PageModulesController < ApplicationController
    def index
      @page_modules = PageModule.all
    end

    def edit
      @page_module = PageModule.includes(:data_function, :render_function).find(params[:id])
    end
  end
end
