module Jigsaw
  class RenderFunctionsController < ApplicationController
    skip_forgery_protection

    def index
      @render_functions = RenderFunction.order(:name)
    end

    def new
      @render_function = RenderFunction.new(language: "jsx", source: "export default function(el, data) {\n  el.innerHTML = '<div></div>';\n}")
    end

    def create
      @render_function = RenderFunction.new(render_function_params)
      if @render_function.save
        redirect_to edit_render_function_path(@render_function)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
      @render_function = RenderFunction.find(params[:id])

      respond_to do |format|
        format.html
        format.js do
          if params[:digest] == @render_function.compiled_digest
            response.headers["Cache-Control"] = "public, max-age=31536000, immutable"
          end
          render plain: @render_function.compiled_source, content_type: "text/javascript"
        end
      end
    end

    def edit
      @render_function = RenderFunction.find(params[:id])
    end

    def update
      @render_function = RenderFunction.find(params[:id])
      if @render_function.update(render_function_params)
        respond_to do |format|
          format.html { redirect_to edit_render_function_path(@render_function) }
          format.js   { render plain: @render_function.compiled_source, content_type: "text/javascript" }
          format.json { render json: { compiled_digest: @render_function.compiled_digest } }
        end
      else
        respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
          format.js   { head :unprocessable_entity }
          format.json { render json: { errors: @render_function.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      render_function = RenderFunction.find(params[:id])
      render_function.destroy!
      redirect_to render_functions_path
    end

    private

    def render_function_params
      params.require(:render_function).permit(:name, :language, :source)
    end
  end
end
