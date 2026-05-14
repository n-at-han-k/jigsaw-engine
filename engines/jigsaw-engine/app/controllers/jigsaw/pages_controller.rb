module Jigsaw
  class PagesController < ApplicationController

    before_action :set_page, only: [:edit, :update, :destroy]

    DEFAULT_GRID_CONFIG = {
      "type"        => "grid",
      "areas"       => [["main"]],
      "columns"     => ["1fr"],
      "rows"        => ["1fr"],
      "gridWidth"   => "100%",
      "gridHeight"  => "100%",
      "rowGap"      => 8,
      "colGap"      => 8,
      "rowGapUnit"  => "px",
      "colGapUnit"  => "px"
    }.freeze

    def index
      @pages = Page.order(:title)
    end

    def new
      @page = Page.new
    end

    def create
      @page = Page.new(page_params)
      if @page.save
        @page.create_layout!(name: "#{@page.title} Layout", config: DEFAULT_GRID_CONFIG.deep_dup)
        @page.layout.sync_slots
        redirect_to edit_page_path(@page), notice: "Page created"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @layout.sync_slots if @layout
      @slots = @layout&.slots&.order(:position) || []
    end

    def update
      if @page.update(page_params)
        @page.layout&.sync_slots
        redirect_to edit_page_path(@page), notice: "Page updated"
      else
        @slots = @layout&.slots&.order(:position) || []
        render :edit, status: :unprocessable_entity
      end
    end

    def show
      @page = Page.find_by!(path: params[:path].to_s.delete_prefix("/"))
      @layout = @page.layout

      if @layout
        @slots = @layout.slots.order(:position)
      else
        @slots = []
      end
    end

    def destroy
      @page.destroy!
      redirect_to pages_path, notice: "Page deleted"
    end

    private

      def set_page
        @page = Page.find(params[:id])
        @layout = @page.layout
      end

      def page_params
        params.require(:page).permit(
          :title,
          :path,

          layout_attributes: [
            :id,
            :config,
            :gridWidth,
            :gridHeight,
            :rowGap,
            :colGap,
            :rowGapUnit,
            :colGapUnit
          ]
        )
      end
  end
end
