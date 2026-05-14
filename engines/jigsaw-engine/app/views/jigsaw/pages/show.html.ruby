Wrapper(data: { controller: "custom-page", "custom-page-page-id-value": @page.id }) {
  Style(@layout.compiled_css)

  Div(class: "jigsaw-layout-#{@layout.id}") {
    @slots.each do |slot|
      Div(class: slot.area_name) {
        CustomModule(
          module_id:           slot.id,
          edit_url:            edit_slot_path(slot),
          data_function_url:   slot.data_source.present? ? data_source_slot_path(slot, digest: slot.data_compiled_digest) : "",
          render_function_url: slot.render_source.present? ? render_source_slot_path(slot, digest: slot.render_compiled_digest) : "",
          config:              slot.config.to_json,
          shares:              slot.shares.to_json
        )
      }
    end
  }
}