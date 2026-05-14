StylesheetLink("jigsaw/grid_resize.css")

Wrapper(data: { controller: "custom-page", "custom-page-page-id-value": @page.id }) {
  Style(@layout.effective_compiled_css)

  Div(
    class: "jigsaw-layout-#{@layout.id}",
    data: {
      controller: "grid-resize",
      "grid-resize-layout-id-value": @layout.id,
      "grid-resize-areas-value": @layout.effective_config["areas"].to_json,
    }
  ) {
    @slots.each do |slot|
      slot_data = slot.effective_config["resizable"] ? { resizable: "true" } : {}
      Div(class: slot.area_name, data: slot_data) {
        CustomModule(
          module_id:           slot.id,
          edit_url:            edit_slot_path(slot),
          data_function_url:   slot.effective_data_source.present? ? data_source_slot_path(slot, digest: slot.effective_data_compiled_digest) : "",
          render_function_url: slot.effective_render_source.present? ? render_source_slot_path(slot, digest: slot.effective_render_compiled_digest) : "",
          config:              slot.effective_config.to_json,
          shares:              slot.effective_shares.to_json
        )
      }
    end
  }
}
