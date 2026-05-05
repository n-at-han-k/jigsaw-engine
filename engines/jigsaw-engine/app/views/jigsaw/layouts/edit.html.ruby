StylesheetLink("jigsaw/layout_editor.css")

Wrapper(data: { controller: "layout-editor" }) {

  Menu(attached: "top") {
    BackButton(href: layouts_path, icon: "arrow left")
    MenuItem(header: true) { text @layout.name }
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
    # --- Center: Preview ---
    Wrapper(class: "editor-center", data: { "layout-editor-target": "preview" })

    # --- Right: Config + Output ---
    Wrapper(class: "editor-output", data: { "layout-editor-target": "panel", action: "input->layout-editor#rebuild" }) {

      Header(size: 5, style: "margin-top: 0;") { text "Grid Settings" }

      # Children
      Wrapper(class: "sidebar-field") {
        Label(for: "childrenCount") { text "Children" }
        Wrapper(class: "sidebar-input-row") {
          Input(type: "text", id: "childrenCount",
                value: @layout.config["childrenCount"] || 9)
        }
      }

      # Rows
      Wrapper(class: "sidebar-field") {
        Label(for: "rowCount") { text "Rows" }
        Wrapper(class: "sidebar-input-row") {
          Input(type: "text", id: "rowCount",
                value: (@layout.config["rows"].is_a?(Array) ? @layout.config["rows"].length : @layout.config["rows"]) || 3)
          Span(class: "unit-btn", style: "cursor: default;") { text "number" }
        }
      }

      # Columns
      Wrapper(class: "sidebar-field") {
        Label(for: "colCount") { text "Columns" }
        Wrapper(class: "sidebar-input-row") {
          Input(type: "text", id: "colCount",
                value: (@layout.config["columns"].is_a?(Array) ? @layout.config["columns"].length : @layout.config["columns"]) || 3)
          Span(class: "unit-btn", style: "cursor: default;") { text "number" }
        }
      }

      # Row Height (default)
      Wrapper(class: "sidebar-field") {
        Label(for: "rowHeight") { text "Row Height" }
        Wrapper(class: "sidebar-input-row") {
          rows = @layout.config["rows"]
          row_height_value = if rows.is_a?(Array) && rows[0].is_a?(Hash)
            rows[0]["value"] || 1
          else
            @layout.config["rowHeight"] || 1
          end
          row_height_unit = if rows.is_a?(Array) && rows[0].is_a?(Hash)
            rows[0]["unit"] || "fr"
          else
            @layout.config["rowHeightUnit"] || "fr"
          end
          Input(type: "text", id: "rowHeight", value: row_height_value)
          Button(type: "button", id: "rowHeightUnit", class: "unit-btn",
                 data: { action: "click->layout-editor#cycleUnit", units: "fr,px,auto" }
          ) { text row_height_unit }
        }
      }

      # Column Width (default)
      Wrapper(class: "sidebar-field") {
        Label(for: "colWidth") { text "Column Width" }
        Wrapper(class: "sidebar-input-row") {
          cols = @layout.config["columns"]
          col_width_value = if cols.is_a?(Array) && cols[0].is_a?(Hash)
            cols[0]["value"] || 1
          else
            @layout.config["colWidth"] || 1
          end
          col_width_unit = if cols.is_a?(Array) && cols[0].is_a?(Hash)
            cols[0]["unit"] || "fr"
          else
            @layout.config["colWidthUnit"] || "fr"
          end
          Input(type: "text", id: "colWidth", value: col_width_value)
          Button(type: "button", id: "colWidthUnit", class: "unit-btn",
                 data: { action: "click->layout-editor#cycleUnit", units: "fr,px,auto" }
          ) { text col_width_unit }
        }
      }

      # Row Gap
      Wrapper(class: "sidebar-field") {
        Label(for: "rowGap") { text "Row Gap" }
        Wrapper(class: "sidebar-input-row") {
          row_gap = @layout.config["rowGap"]
          row_gap_value = if row_gap.is_a?(Hash)
            row_gap["value"] || 8
          else
            row_gap || 8
          end
          row_gap_unit = if row_gap.is_a?(Hash)
            row_gap["unit"] || "px"
          else
            "px"
          end
          Input(type: "text", id: "rowGap", value: row_gap_value)
          Button(type: "button", id: "rowGapUnit", class: "unit-btn",
                 data: { action: "click->layout-editor#cycleUnit", units: "px,rem,%" }
          ) { text row_gap_unit }
        }
      }

      # Column Gap
      Wrapper(class: "sidebar-field") {
        Label(for: "colGap") { text "Column Gap" }
        Wrapper(class: "sidebar-input-row") {
          col_gap = @layout.config["columnGap"]
          col_gap_value = if col_gap.is_a?(Hash)
            col_gap["value"] || 8
          else
            col_gap || 8
          end
          col_gap_unit = if col_gap.is_a?(Hash)
            col_gap["unit"] || "px"
          else
            "px"
          end
          Input(type: "text", id: "colGap", value: col_gap_value)
          Button(type: "button", id: "colGapUnit", class: "unit-btn",
                 data: { action: "click->layout-editor#cycleUnit", units: "px,rem,%" }
          ) { text col_gap_unit }
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
