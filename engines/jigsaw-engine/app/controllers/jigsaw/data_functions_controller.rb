module Jigsaw
  class DataFunctionsController < ApplicationController
    skip_forgery_protection

    def index
      @data_functions = DataFunction.order(:name)
    end

    def new
      @data_function = DataFunction.new(language: "javascript", source: "export default function(ctx) {\n  return {};\n}")
    end

    def create
      @data_function = DataFunction.new(data_function_params)
      if @data_function.save
        redirect_to edit_data_function_path(@data_function)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
      @data_function = DataFunction.find(params[:id])

      respond_to do |format|
        format.html
        format.js do
          if params[:digest] == @data_function.compiled_digest
            response.headers["Cache-Control"] = "public, max-age=31536000, immutable"
          end
          render plain: @data_function.compiled_source, content_type: "text/javascript"
        end
      end
    end

    def edit
      @data_function = DataFunction.find(params[:id])
    end

    def update
      @data_function = DataFunction.find(params[:id])
      if @data_function.update(data_function_params)
        respond_to do |format|
          format.html { redirect_to edit_data_function_path(@data_function) }
          format.js   { render plain: @data_function.compiled_source, content_type: "text/javascript" }
          format.json { render json: { compiled_digest: @data_function.compiled_digest } }
        end
      else
        respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
          format.js   { head :unprocessable_entity }
          format.json { render json: { errors: @data_function.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      data_function = DataFunction.find(params[:id])
      data_function.destroy!
      redirect_to data_functions_path
    end

    private

    def data_function_params
      params.require(:data_function).permit(:name, :language, :source)
    end
  end
end
