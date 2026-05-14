module Jigsaw
  class LayoutTemplatesController < ApplicationController
    before_action :set_layout_template, only: [:edit, :update, :destroy]

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
      @layout_templates = LayoutTemplate.order(:name)
    end

    def new
      @layout_template = LayoutTemplate.new
    end

    def create
      @layout_template = LayoutTemplate.new(layout_template_params)
      @layout_template.config = DEFAULT_GRID_CONFIG.deep_dup if @layout_template.config.blank?
      if @layout_template.save
        redirect_to edit_layout_template_path(@layout_template), notice: "Layout template created"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @layout_template.update(layout_template_params)
        redirect_to edit_layout_template_path(@layout_template), notice: "Layout template updated"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @layout_template.destroy!
      redirect_to layout_templates_path, notice: "Layout template deleted"
    end

    private

      def set_layout_template
        @layout_template = LayoutTemplate.find(params[:id])
      end

      def layout_template_params
        params.require(:layout_template).permit(
          :name,
          :description,
          :thumbnail,
          :config,
          :gridWidth,
          :gridHeight,
          :rowGap,
          :colGap,
          :rowGapUnit,
          :colGapUnit
        )
      end
  end
end
