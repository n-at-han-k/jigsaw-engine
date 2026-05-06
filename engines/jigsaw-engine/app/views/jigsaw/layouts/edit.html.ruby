StylesheetLink("jigsaw/layout_editor.css")

Wrapper(data: { controller: "layout-editor" }) {

  Menu(attached: "top") {
    BackButton(href: layouts_path, icon: "arrow left")
    MenuItem(header: true) { text @layout.name }
    SubMenu(position: "right") {
      MenuItem {
        Button(type: "button", icon: "exchange", size: "tiny",
               data: { action: "click->layout-editor#toggleTracks" }) { text "Tracks" }
      }
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

      is_flex = @layout.config["type"] == "flex"

      # Children
      Wrapper(class: "sidebar-field") {
        Label(for: "childrenCount") { text "Children" }
        Wrapper(class: "sidebar-input-row") {
          Input(type: "text", id: "childrenCount",
                value: @layout.config["childrenCount"] || 3)
        }
      }

      # Type toggle (Grid / Flexbox)
      Wrapper(class: "sidebar-field") {
        Wrapper(class: "sidebar-input-row type-toggle") {
          Button(type: "button", id: "typeGrid", class: "type-btn #{is_flex ? '' : 'active'}",
                 data: { action: "click->layout-editor#setTypeGrid" }) { text "Grid" }
          Button(type: "button", id: "typeFlex", class: "type-btn #{is_flex ? 'active' : ''}",
                 data: { action: "click->layout-editor#setTypeFlex" }) { text "Flexbox" }
        }
      }

      # --- Grid-specific fields ---
      Wrapper(class: "grid-fields", data: { "layout-editor-target": "gridFields" }, style: is_flex ? "display:none;" : "") {

        # Rows
        Wrapper(class: "sidebar-field") {
          Label(for: "rowCount") { text "Rows" }
          Wrapper(class: "sidebar-input-row") {
            rows = @layout.config["rows"]
            row_count = if rows.is_a?(Array)
              rows.length
            elsif rows.is_a?(Hash)
              rows["repeat"] || 3
            else
              3
            end
            Input(type: "text", id: "rowCount", value: row_count)
            rows_mode = rows.is_a?(Hash) ? rows["repeat"] : "number"
            Button(type: "button", id: "rowsMode", class: "unit-btn",
                   data: { action: "click->layout-editor#cycleRowsMode", units: "number,auto-fit,auto-fill" }
            ) { text rows_mode }
          }
        }

        # Columns
        Wrapper(class: "sidebar-field") {
          Label(for: "colCount") { text "Columns" }
          Wrapper(class: "sidebar-input-row") {
            cols = @layout.config["columns"]
            col_count = cols.is_a?(Array) ? cols.length : 3
            Input(type: "text", id: "colCount", value: col_count)
            Span(class: "unit-btn", style: "cursor: default;") { text "number" }
          }
        }

        # Row Height
        Wrapper(class: "sidebar-field") {
          Label(for: "rowHeight") { text "Row Height" }
          Wrapper(class: "sidebar-input-row") {
            rows = @layout.config["rows"]
            row_height_value = if rows.is_a?(Array) && rows[0].is_a?(Hash)
              rows[0]["value"] || 1
            elsif rows.is_a?(Hash)
              rows["value"] || 1
            else
              1
            end
            row_height_unit = if rows.is_a?(Array) && rows[0].is_a?(Hash)
              rows[0]["unit"] || "fr"
            elsif rows.is_a?(Hash)
              rows["unit"] || "fr"
            else
              "fr"
            end
            Input(type: "text", id: "rowHeight", value: row_height_value)
            Button(type: "button", id: "rowHeightUnit", class: "unit-btn",
                   data: { action: "click->layout-editor#cycleUnit", units: "fr,px,auto" }
            ) { text row_height_unit }
          }
        }

        # Column Width
        Wrapper(class: "sidebar-field") {
          Label(for: "colWidth") { text "Column Width" }
          Wrapper(class: "sidebar-input-row") {
            cols = @layout.config["columns"]
            col_width_value = if cols.is_a?(Array) && cols[0].is_a?(Hash)
              cols[0]["value"] || 1
            else
              1
            end
            col_width_unit = if cols.is_a?(Array) && cols[0].is_a?(Hash)
              cols[0]["unit"] || "fr"
            else
              "fr"
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
            Input(type: "text", id: "rowGap", value: @layout.config["rowGap"] || 8)
            Button(type: "button", id: "rowGapUnit", class: "unit-btn",
                   data: { action: "click->layout-editor#cycleUnit", units: "px,rem,%" }
            ) { text @layout.config["rowGapUnit"] || "px" }
          }
        }

        # Column Gap
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

        # Grid Areas mode
        Wrapper(class: "sidebar-field") {
          Label { text "Grid Areas" }
          Wrapper(class: "sidebar-input-row") {
            grid_areas_mode = @layout.config["gridAreasMode"] || "names"
            Button(type: "button", id: "gridAreasMode", class: "unit-btn",
                   data: { action: "click->layout-editor#cycleUnit", units: "names,line numbers" }
            ) { text grid_areas_mode }
          }
        }

        # Direction
        Wrapper(class: "sidebar-field") {
          Label { text "Direction" }
          Wrapper(class: "sidebar-input-row") {
            direction = @layout.config["direction"] || "row"
            Button(type: "button", id: "gridDirection", class: "unit-btn",
                   data: { action: "click->layout-editor#cycleUnit", units: "row,column" }
            ) { text direction }
          }
        }

        # Empty Space
        Wrapper(class: "sidebar-field") {
          Label { text "Empty Space" }
          Wrapper(class: "sidebar-input-row") {
            empty_space = @layout.config["emptySpace"] || "dont-fill"
            Button(type: "button", id: "gridEmptySpace", class: "unit-btn",
                   data: { action: "click->layout-editor#cycleUnit", units: "dont-fill,fill" }
            ) { text empty_space }
          }
        }

        Wrapper(class: "panel-divider")

        # Container Alignment
        Header(size: 5) { text "Container Alignment" }

        Wrapper(class: "sidebar-field") {
          Label { text "Horizontal" }
          Wrapper(class: "sidebar-input-row") {
            h_align = (@layout.config.dig("containerAlignment", "horizontal")) || "stretch"
            Button(type: "button", id: "gridContainerH", class: "unit-btn",
                   data: { action: "click->layout-editor#cycleUnit", units: "stretch,start,end,center,space-between,space-around,space-evenly" }
            ) { text h_align }
          }
        }

        Wrapper(class: "sidebar-field") {
          Label { text "Vertical" }
          Wrapper(class: "sidebar-input-row") {
            v_align = (@layout.config.dig("containerAlignment", "vertical")) || "stretch"
            Button(type: "button", id: "gridContainerV", class: "unit-btn",
                   data: { action: "click->layout-editor#cycleUnit", units: "stretch,start,end,center,space-between,space-around,space-evenly" }
            ) { text v_align }
          }
        }

        Wrapper(class: "panel-divider")

        # Children Alignment
        Header(size: 5) { text "Children Alignment" }

        Wrapper(class: "sidebar-field") {
          Label { text "Horizontal" }
          Wrapper(class: "sidebar-input-row") {
            h_align = (@layout.config.dig("childrenAlignment", "horizontal")) || "stretch"
            Button(type: "button", id: "gridChildrenH", class: "unit-btn",
                   data: { action: "click->layout-editor#cycleUnit", units: "stretch,start,end,center" }
            ) { text h_align }
          }
        }

        Wrapper(class: "sidebar-field") {
          Label { text "Vertical" }
          Wrapper(class: "sidebar-input-row") {
            v_align = (@layout.config.dig("childrenAlignment", "vertical")) || "stretch"
            Button(type: "button", id: "gridChildrenV", class: "unit-btn",
                   data: { action: "click->layout-editor#cycleUnit", units: "stretch,start,end,center" }
            ) { text v_align }
          }
        }
      }

      # --- Flex-specific fields ---
      Wrapper(class: "flex-fields", data: { "layout-editor-target": "flexFields" }, style: is_flex ? "" : "display:none;") {

        # Gap
        Wrapper(class: "sidebar-field") {
          Label(for: "flexGap") { text "Gap" }
          Wrapper(class: "sidebar-input-row") {
            Input(type: "text", id: "flexGap", value: @layout.config["gap"] || 16)
            Button(type: "button", id: "flexGapUnit", class: "unit-btn",
                   data: { action: "click->layout-editor#cycleUnit", units: "px,rem,%" }
            ) { text @layout.config["gapUnit"] || "px" }
          }
        }

        Wrapper(class: "panel-divider")

        # Direction
        Wrapper(class: "sidebar-field") {
          Label { text "Direction" }
          Wrapper(class: "sidebar-input-row") {
            direction = @layout.config["direction"] || "row"
            Button(type: "button", id: "flexDirection", class: "unit-btn",
                   data: { action: "click->layout-editor#cycleUnit", units: "row,column,row-reverse,column-reverse" }
            ) { text direction }
          }
        }

        # Wrap
        Wrapper(class: "sidebar-field") {
          Label { text "Wrap" }
          Wrapper(class: "sidebar-input-row") {
            wrap = @layout.config["wrap"] || "nowrap"
            Button(type: "button", id: "flexWrap", class: "unit-btn",
                   data: { action: "click->layout-editor#cycleUnit", units: "nowrap,wrap,wrap-reverse" }
            ) { text wrap }
          }
        }

        Wrapper(class: "panel-divider")

        # Container Alignment
        Header(size: 5) { text "Container Alignment" }

        Wrapper(class: "sidebar-field") {
          Label { text "Main Axis" }
          Wrapper(class: "sidebar-input-row") {
            main_axis = (@layout.config.dig("containerAlignment", "mainAxis")) || "flex-start"
            Button(type: "button", id: "flexMainAxis", class: "unit-btn",
                   data: { action: "click->layout-editor#cycleUnit", units: "flex-start,flex-end,center,space-between,space-around,space-evenly" }
            ) { text main_axis }
          }
        }

        Wrapper(class: "sidebar-field") {
          Label { text "Cross Axis" }
          Wrapper(class: "sidebar-input-row") {
            cross_axis = (@layout.config.dig("containerAlignment", "crossAxis")) || "stretch"
            Button(type: "button", id: "flexCrossAxis", class: "unit-btn",
                   data: { action: "click->layout-editor#cycleUnit", units: "stretch,flex-start,flex-end,center,baseline" }
            ) { text cross_axis }
          }
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
