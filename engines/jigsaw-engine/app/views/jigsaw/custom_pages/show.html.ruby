Wrapper(data: { controller: "custom-page", "custom-page-page-id-value": @page.id }) {
  Header(size: 2) { text @page.title }

  @page_modules.each do |mod|
    CustomModule(
      module_id:          mod.id,
      edit_url:           edit_page_module_path(mod),
      data_function_url:  data_function_path(mod.data_function, digest: mod.data_function.compiled_digest, format: :js),
      render_function_url: render_function_path(mod.render_function, digest: mod.render_function.compiled_digest, format: :js),
      config:             mod.config.to_json,
      shares:             mod.shares.to_json,
      slot:               mod.slot
    )
  end
}
