module Jigsaw
  class LayoutsController < ApplicationController
    skip_forgery_protection

    def index
      @layouts = Layout.order(:name)
    end

    def new
      @layout = Layout.new(config: default_config("grid"))
    end

    def create
      @layout = Layout.new(layout_params)
      @layout.config = default_config(@layout.config["type"] || "grid") if @layout.config.blank?

      if @layout.save
        redirect_to edit_layout_path(@layout)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @layout = Layout.find(params[:id])
    end

    def show
      layout = Layout.find(params[:id])

      if params[:digest] == layout.compiled_digest
        response.headers["Cache-Control"] = "public, max-age=31536000, immutable"
      end

      render plain: layout.compiled_css, content_type: "text/css"
    end

    def update
      @layout = Layout.find(params[:id])
      if @layout.update(layout_params)
        redirect_to edit_layout_path(@layout)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      layout = Layout.find(params[:id])
      layout.destroy!
      redirect_to layouts_path
    end

    private

    def layout_params
      permitted = params.require(:layout).permit(:name, :config)
      if permitted[:config].is_a?(String)
        permitted[:config] = JSON.parse(permitted[:config])
      end
      permitted
    end

    def default_config(type)
      if type == "flex"
        {
          "type" => "flex",
          "direction" => "row",
          "wrap" => "nowrap",
          "justifyContent" => "start",
          "alignItems" => "stretch",
          "alignContent" => "stretch",
          "rowGap" => { "value" => 0, "unit" => "px" },
          "columnGap" => { "value" => 8, "unit" => "px" },
          "childrenCount" => 3
        }
      else
        {
          "type" => "grid",
          "childrenCount" => 9,
          "columns" => [
            { "value" => 1, "unit" => "fr" },
            { "value" => 1, "unit" => "fr" },
            { "value" => 1, "unit" => "fr" }
          ],
          "rows" => [
            { "value" => 1, "unit" => "fr" },
            { "value" => 1, "unit" => "fr" },
            { "value" => 1, "unit" => "fr" }
          ],
          "rowGap" => { "value" => 8, "unit" => "px" },
          "columnGap" => { "value" => 8, "unit" => "px" },
          "areas" => []
        }
      end
    end
  end
end
