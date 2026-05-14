module Jigsaw
  class SlotsController < ApplicationController
    skip_forgery_protection only: [:data_source, :render_source]
    before_action :set_slot, only: [:edit, :update, :data_source, :render_source, :unlink_template, :link_template]

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
      render plain: @slot.effective_data_compiled_source || ""
    end

    def render_source
      response.headers["Content-Type"] = "text/javascript"
      render plain: @slot.effective_render_compiled_source || ""
    end

    def unlink_template
      @slot.unlink_from_template!
      redirect_to edit_slot_path(@slot), notice: "Slot unlinked from template"
    end

    def link_template
      slot_template = SlotTemplate.find(params[:slot_template_id])
      @slot.link_to_template!(slot_template)
      redirect_to edit_slot_path(@slot), notice: "Slot linked to template: #{slot_template.name}"
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
