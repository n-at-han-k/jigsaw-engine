module Jigsaw
  class PageModulesController < ApplicationController

    skip_forgery_protection only: [:data_source, :render_source]
    before_action :set_module, only: [:edit, :update]

    def index
      @modules = PageModule.all
    end

    def edit
    end

    def update
      if @module.update(module_params)
        # no idea
      else
        # no idea
      end
    end

    def data_source
      mod = PageModule.find(params[:id])
      response.headers["Content-Type"] = "text/javascript"
      render plain: mod.data_compiled_source || ""
    end

    def render_source
      mod = PageModule.find(params[:id])
      response.headers["Content-Type"] = "text/javascript"
      render plain: mod.render_compiled_source || ""
    end

    private

      def set_module
        @module = PageModule.find(params[:id])
      end

      def module_params
        params.require(:page_module).permit(
          :data_source, :render_source, :render_language, :config
        )
      end
  end
end
