CustomModule(
  module_id: page_module.id,
  edit_url:  edit_page_module_path(page_module),
  config:    page_module.config.to_json,
  shares:    page_module.shares.to_json,
  data:      { "page-editor-target": "cell" },

  data_function_url: data_source_page_module_path(page_module, digest: page_module.data_compiled_digest),
  render_function_url: render_source_page_module_path(page_module, digest: page_module.render_compiled_digest),
)
