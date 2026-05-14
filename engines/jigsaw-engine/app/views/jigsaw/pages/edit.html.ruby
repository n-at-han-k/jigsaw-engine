StylesheetLink("jigsaw/layout_editor.css")

slot_id_by_area = @slots.each_with_object({}) { |s, h| h[s.area_name] = s.id }
slot_edit_paths = @slots.each_with_object({}) { |s, h| h[s.area_name] = edit_slot_path(s) }

Wrapper(
  data: {
    controller: "layout-editor",
    "layout-editor-slots-by-area-value": slot_id_by_area.to_json,
    "layout-editor-slot-edit-paths-value": slot_edit_paths.to_json
  }
) {

  Menu(attached: "top") {
    BackButton(href: pages_path, icon: "arrow left")

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
          url: page_path(@page),
          method: :delete,
          color: "red",
          size: "tiny",
          confirm: "Delete this page?",
          icon: "trash"
        ) { "Delete" }
      }
      MenuItem {
        Button(
          type: "submit",
          form: "page-form",
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
