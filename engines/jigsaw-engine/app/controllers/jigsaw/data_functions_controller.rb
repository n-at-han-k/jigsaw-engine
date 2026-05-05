module Jigsaw
  class DataFunctionsController < ApplicationController
    skip_forgery_protection

    def show
      func = DataFunction.find(params[:id])

      if params[:digest] == func.compiled_digest
        response.headers["Cache-Control"] = "public, max-age=31536000, immutable"
      end

      render plain: func.compiled_source, content_type: "text/javascript"
    end

    def update
      func = DataFunction.find(params[:id])
      if func.update(params.require(:data_function).permit(:source))
        render json: { compiled_digest: func.compiled_digest }
      else
        render json: { errors: func.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
