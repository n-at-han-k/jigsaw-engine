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
    MenuItem(header: true) { text @page.title }
    SubMenu(position: "right") {
      MenuItem {
        Button(type: "button", icon: "sidebar", size: "tiny",
               data: { action: "click->layout-editor#togglePanel" }) { text "Panel" }
      }
      MenuItem {
        Form(model: @layout, style: "display: inline;") {
          HiddenField(:config, id: "configHidden", value: @layout.config.to_json,
                      data: { "layout-editor-target": "configHidden" })
          Submit("Save", color: "green", size: "tiny")
        }
      }
    }
  }

  Wrapper(class: "editor-page") {
    Wrapper(class: "editor-center", data: { "layout-editor-target": "preview" })

    Wrapper(class: "editor-output", data: { "layout-editor-target": "panel", action: "input->layout-editor#rebuild" }) {

      Wrapper(class: "sidebar-field") {
        Label(for: "gridWidth") { text "Width" }
        Wrapper(class: "sidebar-input-row") {
          Input(type: "text", id: "gridWidth", value: @layout.config["gridWidth"] || "100%")
        }
      }

      Wrapper(class: "sidebar-field") {
        Label(for: "gridHeight") { text "Height" }
        Wrapper(class: "sidebar-input-row") {
          Input(type: "text", id: "gridHeight", value: @layout.config["gridHeight"] || "100%")
        }
      }

      Wrapper(class: "sidebar-field") {
        Label(for: "rowGap") { text "Row Gap" }
        Wrapper(class: "sidebar-input-row") {
          Input(type: "text", id: "rowGap", value: @layout.config["rowGap"] || 8)
          Button(type: "button", id: "rowGapUnit", class: "unit-btn",
                 data: { action: "click->layout-editor#cycleUnit", units: "px,rem,%" }
          ) { text @layout.config["rowGapUnit"] || "px" }
        }
      }

      Wrapper(class: "sidebar-field") {
        Label(for: "colGap") { text "Column Gap" }
        Wrapper(class: "sidebar-input-row") {
          Input(type: "text", id: "colGap", value: @layout.config["colGap"] || 8)
          Button(type: "button", id: "colGapUnit", class: "unit-btn",
                 data: { action: "click->layout-editor#cycleUnit", units: "px,rem,%" }
          ) { text @layout.config["colGapUnit"] || "px" }
        }
      }

      Wrapper(class: "panel-divider")

      Header(size: 5) { text "CSS" }
      Pre(data: { "layout-editor-target": "cssOutput" }, class: "code-output")
      Header(size: 5) { text "HTML" }
      Pre(data: { "layout-editor-target": "htmlOutput" }, class: "code-output")
      Header(size: 5) { text "JSON" }
      Pre(data: { "layout-editor-target": "jsonOutput" }, class: "code-output")
    }
  }
}
