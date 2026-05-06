Partial("jigsaw/data_functions/_shared/menu")

Container(style: "padding: 1rem") {
  Form(model: @data_function, url: data_function_path(@data_function), method: :patch) {
    TextField(:name, required: true)

    Wrapper(
      data: { controller: "monaco-editor", "monaco-editor-language": "javascript" },
      style: "height: 60vh;"
    ) {
      HiddenField(:source, data: { "monaco-editor-target": "field" })
      Wrapper(data: { "monaco-editor-target": "container" }, style: "height: calc(100% - 24px);")
      Wrapper(data: { "monaco-editor-target": "status" }, style: "height: 24px; background: #1e1e1e; color: #fff; font-size: 12px; padding: 2px 8px;")
    }

    Wrapper(style: "margin-top: 1em;") {
      Submit("Save", color: "green")
      LinkTo(href: data_functions_path, class: "ui button") { text "Cancel" }
    }
  }
}
