TurboFrame(id: "editor") {
  Wrapper(
    data: {
      controller: "module-editor",
      "module-editor-module-id-value": @slot_template.id,
      "module-editor-data-source-value": @slot_template.data_source || "",
      "module-editor-render-source-value": @slot_template.render_source || "",
      "module-editor-render-language-value": @slot_template.render_language || "javascript",
      "module-editor-config-value": (@slot_template.config || {}).to_json,
      "module-editor-save-url-value": slot_template_path(@slot_template)
    }
  ) {
    Header(size: 4) { text "Slot Template: #{@slot_template.name}" }

    if @slot_template.tag_list.any?
      Wrapper(style: "margin-bottom: 0.5em;") {
        @slot_template.tag_list.each do |tag_name|
          Wrapper(html_class: "ui mini label") { text tag_name }
        end
      }
    end

    Menu(attached: "top", tabular: true) {
      MenuItem(data: { "module-editor-target": "tab", tab: "data", action: "click->module-editor#switchTab" }) { text "Data" }
      MenuItem(active: true, data: { "module-editor-target": "tab", tab: "render", action: "click->module-editor#switchTab" }) { text "Render" }
      MenuItem(data: { "module-editor-target": "tab", tab: "config", action: "click->module-editor#switchTab" }) { text "Config" }
    }

    Wrapper(
      data: { controller: "monaco-editor", "monaco-editor-language": "javascript" },
      style: "height: 60vh;"
    ) {
      Wrapper(data: { "monaco-editor-target": "container", "module-editor-target": "editorContainer" }, style: "height: calc(100% - 24px);")
      Wrapper(data: { "monaco-editor-target": "status" }, style: "height: 24px; background: #1e1e1e; color: #fff; font-size: 12px; padding: 2px 8px;")
    }

    Wrapper(style: "margin-top: 1em;") {
      Button(color: "blue", data: { action: "module-editor#hotSwap" }) { text "Hot Swap" }
      Button(color: "green", data: { action: "module-editor#save" }) { text "Save" }
    }
  }
}
