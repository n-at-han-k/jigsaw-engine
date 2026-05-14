module Jigsaw
  class PagesController < ApplicationController
    before_action :set_page, only: [:edit, :update]

    def index
      @pages = Page.order(:title)
    end

    def edit
    end

    def update
      if @page.update(page_params)
        redirect_to edit_page_path(@page), notice: "Page updated"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def show
      @page = Page.find_by!(path: params[:path].to_s.delete_prefix("/"))
      @layout = @page.layout
      @slots = @layout.slots.order(:position)
    end

    private

      def set_page
        @page = Page.find(params[:id])
        @layout = @page.layout
        @slots = @layout.slots.order(:position)
      end

      def page_params
        params.require(:page).permit(:title, :path)
      end
  end
end
