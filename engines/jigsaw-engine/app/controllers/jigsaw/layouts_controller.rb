module Jigsaw
  class LayoutsController < ApplicationController
    before_action :set_layout, only: [:show, :edit, :update, :destroy]

    def index
      @layouts = Layout.order(:name)
    end

    def show
    end

    def new
      @layout = Layout.new(config: default_grid_config)
    end

    def create
      @layout = Layout.new(layout_params)
      if @layout.save
        @layout.sync_slots
        redirect_to edit_layout_path(@layout), notice: "Layout created"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @layout.sync_slots if @layout.persisted?
    end

    def update
      if @layout.update(layout_params)
        @layout.sync_slots
        redirect_to edit_layout_path(@layout), notice: "Layout updated"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @layout.destroy!
      redirect_to layouts_path, notice: "Layout deleted"
    end

    private

      def set_layout
        @layout = Layout.find(params[:id])
      end

      def layout_params
        params.require(:layout).permit(:name, :config)
      end

      def default_grid_config
        {
          "type" => "grid",
          "areas" => [
            ["header", "header", "header"],
            ["left", "main", "right"],
            ["footer", "footer", "footer"]
          ],
          "columns" => ["120px", "4fr", "1fr"],
          "rows" => ["160px", "1fr", "80px"],
          "gridWidth" => "100%",
          "gridHeight" => "100%",
          "rowGap" => 8,
          "colGap" => 8,
          "rowGapUnit" => "px",
          "colGapUnit" => "px"
        }
      end
  end
end
