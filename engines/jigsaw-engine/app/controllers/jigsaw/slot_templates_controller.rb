module Jigsaw
  class SlotTemplatesController < ApplicationController
    skip_forgery_protection only: [:data_source, :render_source]
    before_action :set_slot_template, only: [:show, :edit, :update, :destroy, :data_source, :render_source]

    def index
      @slot_templates = if params[:tag].present?
        SlotTemplate.tagged_with(params[:tag])
      else
        SlotTemplate.all
      end
      @slot_templates = @slot_templates.order(:name)
      @tags = SlotTemplate.tag_counts_on(:tags).order(:name)
    end

    def new
      @slot_template = SlotTemplate.new
    end

    def create
      @slot_template = SlotTemplate.new(slot_template_params)
      if @slot_template.save
        redirect_to slot_templates_path, notice: "Slot template created"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
    end

    def edit
    end

    def update
      if @slot_template.update(slot_template_params)
        head :ok
      else
        render json: { errors: @slot_template.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @slot_template.destroy!
      redirect_to slot_templates_path, notice: "Slot template deleted"
    end

    def data_source
      response.headers["Content-Type"] = "text/javascript"
      render plain: @slot_template.data_compiled_source || ""
    end

    def render_source
      response.headers["Content-Type"] = "text/javascript"
      render plain: @slot_template.render_compiled_source || ""
    end

    private

      def set_slot_template
        @slot_template = SlotTemplate.find(params[:id])
      end

      def slot_template_params
        params.require(:slot_template).permit(
          :name, :description, :thumbnail, :data_source,
          :render_source, :render_language, :config, :tag_list
        )
      end
  end
end
