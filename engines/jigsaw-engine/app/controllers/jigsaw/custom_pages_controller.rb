module Jigsaw
  class CustomPagesController < ApplicationController

    before_action :set_page, only: [:edit, :update]

    def index
      @pages = CustomPage.order(:title)
    end

    def edit
    end

    def update
      if @page.update(page_params)
        # NOTE: add flash notice
        redirect_to edit_custom_page_path(@page)
      else
        # NOTE: add flash notice
        render :edit, :unprocessable_entity
      end
    end

    private

      def set_page
        @page = CustomPage.find(params[:id])
        @layout = @page.layout
        @modules = @layout.page_modules.order(:position)
      end

      def page_params
        params.require(:custom_page).permit!
      end
  end
end
