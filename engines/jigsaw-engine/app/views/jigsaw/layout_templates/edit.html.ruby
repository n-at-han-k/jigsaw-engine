StylesheetLink("jigsaw/layout_editor.css")

Wrapper(
  data: {
    controller: "layout-editor",
    "layout-editor-slots-by-area-value": "{}",
    "layout-editor-slot-edit-paths-value": "{}"
  }
) {

  Menu(attached: "top") {
    BackButton(href: layout_templates_path, icon: "arrow left")

    SubMenu(position: "right") {
      MenuItem {
        Button(
          type: "button",
          icon: "sidebar",
          size: "tiny",
          data: { action: "click->layout-editor#togglePanel" }
        ) { "Panel" }
      }
      MenuItem {
        ButtonTo(
          url: layout_template_path(@layout_template),
          method: :delete,
          color: "red",
          size: "tiny",
          confirm: "Delete this layout template?",
          icon: "trash"
        ) { "Delete" }
      }
      MenuItem {
        Button(
          type: "submit",
          form: "layout-template-form",
          color: "green",
          size: "tiny"
        ) { "Save" }
      }
    }
  }

  Wrapper(class: "editor-page") {
    Wrapper(
      class: "editor-center",
      data: { "layout-editor-target": "preview" }
    )

    Wrapper(
      class: "editor-output",
      data: {
        "layout-editor-target": "panel",
        action: "input->layout-editor#rebuild"
      }
    ) {

      Partial("form")

      Wrapper(html_class: "panel-divider")

      Header(size: 5) { "CSS" }
      Pre(data: { "layout-editor-target": "cssOutput" }, class: "code-output")

      Header(size: 5) { "HTML" }
      Pre(data: { "layout-editor-target": "htmlOutput" }, class: "code-output")

      Header(size: 5) { "JSON" }
      Pre(data: { "layout-editor-target": "jsonOutput" }, class: "code-output")
    }
  }
}
