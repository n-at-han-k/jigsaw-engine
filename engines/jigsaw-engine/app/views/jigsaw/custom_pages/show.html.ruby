Wrapper(data: { controller: "custom-page", "custom-page-page-id-value": @page.id }) {
  Header(size: 2) { text @page.title }

  @page_modules.each do |mod|
    CustomModule(
      module_id:           mod.id,
      edit_url:            edit_page_module_path(mod),
      data_function_url:   mod.data_source.present? ? data_source_page_module_path(mod, digest: mod.data_compiled_digest) : "",
      render_function_url: mod.render_source.present? ? render_source_page_module_path(mod, digest: mod.render_compiled_digest) : "",
      config:              mod.config.to_json,
      shares:              mod.shares.to_json
    )
  end
}
