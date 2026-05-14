CustomModule(
  module_id: slot.id,
  edit_url:  edit_slot_path(slot),
  config:    slot.config.to_json,
  shares:    slot.shares.to_json,
  data:      { "page-editor-target": "cell", style: "grid-area: #{slot.area_name}" },

  data_function_url: data_source_slot_path(slot, digest: slot.data_compiled_digest),
  render_function_url: render_source_slot_path(slot, digest: slot.render_compiled_digest),
)
