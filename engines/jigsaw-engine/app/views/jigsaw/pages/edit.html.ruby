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

  # Single combined Page+Layout form. Submits to PATCH /pages/:id with
  # nested layout_attributes so a single save persists everything atomically.
  Form(model: @page, html: { style: "display: contents;" }) {

    Menu(attached: "top") {
      BackButton(href: pages_path, icon: "arrow left")

      MenuItem(style: "padding: 4px 12px;") {
        TextField(:title, label: false, placeholder: "Page title",
                  style: "min-width: 180px; margin: 0;", field: true)
      }

      MenuItem(style: "padding: 4px 12px;") {
        TextField(:path, label: false, placeholder: "route/path",
                  style: "min-width: 160px; margin: 0;", field: true)
      }

      SubMenu(position: "right") {
        MenuItem {
          Button(type: "button", icon: "sidebar", size: "tiny",
                 data: { action: "click->layout-editor#togglePanel" }) { text "Panel" }
        }
        MenuItem {
          ButtonTo(url: page_path(@page), method: :delete, color: "red", size: "tiny",
                   confirm: "Delete this page?", icon: "trash") { text "Delete" }
        }
        MenuItem {
          # Nested layout id/config via raw inputs (one combined save).
          text hidden_field_tag("page[layout_attributes][id]", @layout.id)
          text hidden_field_tag(
            "page[layout_attributes][config]",
            @layout.config.to_json,
            id: "configHidden",
            data: { "layout-editor-target": "configHidden" }
          )
          Submit("Save", color: "green", size: "tiny")
        }
      }
    }

    Wrapper(html_class: "editor-page") {
      Wrapper(html_class: "editor-center", data: { "layout-editor-target": "preview" })

      Wrapper(html_class: "editor-output",
              data: { "layout-editor-target": "panel", action: "input->layout-editor#rebuild" }) {

        Wrapper(html_class: "sidebar-field") {
          Label(for: "gridWidth") { text "Width" }
          Wrapper(html_class: "sidebar-input-row") {
            Input(type: "text", id: "gridWidth", value: @layout.config["gridWidth"] || "100%")
          }
        }

        Wrapper(html_class: "sidebar-field") {
          Label(for: "gridHeight") { text "Height" }
          Wrapper(html_class: "sidebar-input-row") {
            Input(type: "text", id: "gridHeight", value: @layout.config["gridHeight"] || "100%")
          }
        }

        Wrapper(html_class: "sidebar-field") {
          Label(for: "rowGap") { text "Row Gap" }
          Wrapper(html_class: "sidebar-input-row") {
            Input(type: "text", id: "rowGap", value: @layout.config["rowGap"] || 8)
            Button(type: "button", id: "rowGapUnit", class: "unit-btn",
                   data: { action: "click->layout-editor#cycleUnit", units: "px,rem,%" }
            ) { text @layout.config["rowGapUnit"] || "px" }
          }
        }

        Wrapper(html_class: "sidebar-field") {
          Label(for: "colGap") { text "Column Gap" }
          Wrapper(html_class: "sidebar-input-row") {
            Input(type: "text", id: "colGap", value: @layout.config["colGap"] || 8)
            Button(type: "button", id: "colGapUnit", class: "unit-btn",
                   data: { action: "click->layout-editor#cycleUnit", units: "px,rem,%" }
            ) { text @layout.config["colGapUnit"] || "px" }
          }
        }

        Wrapper(html_class: "panel-divider")

        Header(size: 5) { text "CSS" }
        Pre(data: { "layout-editor-target": "cssOutput" }, class: "code-output")
        Header(size: 5) { text "HTML" }
        Pre(data: { "layout-editor-target": "htmlOutput" }, class: "code-output")
        Header(size: 5) { text "JSON" }
        Pre(data: { "layout-editor-target": "jsonOutput" }, class: "code-output")
      }
    }
  }
}
