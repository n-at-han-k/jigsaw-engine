module Jigsaw
  class SlotsController < ApplicationController
    skip_forgery_protection only: [:data_source, :render_source]
    before_action :set_slot, only: [:edit, :update, :data_source, :render_source]

    def index
      @slots = Slot.all
    end

    def edit
    end

    def update
      if @slot.update(slot_params)
        head :ok
      else
        render json: { errors: @slot.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def data_source
      response.headers["Content-Type"] = "text/javascript"
      render plain: @slot.data_compiled_source || ""
    end

    def render_source
      response.headers["Content-Type"] = "text/javascript"
      render plain: @slot.render_compiled_source || ""
    end

    private

      def set_slot
        @slot = Slot.find(params[:id])
      end

      def slot_params
        params.require(:slot).permit(
          :area_name, :data_source, :render_source, :render_language, :config
        )
      end
  end
end
