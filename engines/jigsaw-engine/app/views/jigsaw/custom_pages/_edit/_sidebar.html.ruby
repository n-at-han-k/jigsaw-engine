Wrapper() {

  Form(model: @layout) {

    NumberField(:children_count)
    NumberField(:row_count)
    NumberField(:col_count)
    NumberField(:row_height)
    NumberField(:col_width)
    NumberField(:row_gap)
    NumberField(:col_gap)

    # Type toggle (Grid / Flexbox)
    #Wrapper(class: "sidebar-field") {
    #  Wrapper(class: "sidebar-input-row type-toggle") {
    #    Button(type: "button", id: "typeGrid", class: "type-btn #{is_flex ? '' : 'active'}",
    #           data: { action: "click->page-editor#setTypeGrid" }) { text "Grid" }
    #    Button(type: "button", id: "typeFlex", class: "type-btn #{is_flex ? 'active' : ''}",
    #           data: { action: "click->page-editor#setTypeFlex" }) { text "Flexbox" }
    #  }
    #}


    #Wrapper(class: "panel-divider")

    ## Grid Areas mode
    #Wrapper(class: "sidebar-field") {
    #  Label { text "Grid Areas" }
    #  Wrapper(class: "sidebar-input-row") {
    #    grid_areas_mode = @layout.config["gridAreasMode"] || "names"
    #    Button(type: "button", id: "gridAreasMode", class: "unit-btn",
    #           data: { action: "click->page-editor#cycleUnit", units: "names,line numbers" }
    #    ) { text grid_areas_mode }
    #  }
    #}

    ## Direction
    #Wrapper(class: "sidebar-field") {
    #  Label { text "Direction" }
    #  Wrapper(class: "sidebar-input-row") {
    #    direction = @layout.config["direction"] || "row"
    #    Button(type: "button", id: "gridDirection", class: "unit-btn",
    #           data: { action: "click->page-editor#cycleUnit", units: "row,column" }
    #    ) { text direction }
    #  }
    #}

    # Empty Space
    #Wrapper(class: "sidebar-field") {
    #  Label { text "Empty Space" }
    #  Wrapper(class: "sidebar-input-row") {
    #    empty_space = @layout.config["emptySpace"] || "dont-fill"
    #    Button(type: "button", id: "gridEmptySpace", class: "unit-btn",
    #           data: { action: "click->page-editor#cycleUnit", units: "dont-fill,fill" }
    #    ) { text empty_space }
    #  }
    #}

    #Wrapper(class: "panel-divider")

    ## Container Alignment
    #Header(size: 5) { text "Container Alignment" }

    #Wrapper(class: "sidebar-field") {
    #  Label { text "Horizontal" }
    #  Wrapper(class: "sidebar-input-row") {
    #    h_align = (@layout.config.dig("containerAlignment", "horizontal")) || "stretch"
    #    Button(type: "button", id: "gridContainerH", class: "unit-btn",
    #           data: { action: "click->page-editor#cycleUnit", units: "stretch,start,end,center,space-between,space-around,space-evenly" }
    #    ) { text h_align }
    #  }
    #}

    #Wrapper(class: "sidebar-field") {
    #  Label { text "Vertical" }
    #  Wrapper(class: "sidebar-input-row") {
    #    v_align = (@layout.config.dig("containerAlignment", "vertical")) || "stretch"
    #    Button(type: "button", id: "gridContainerV", class: "unit-btn",
    #           data: { action: "click->page-editor#cycleUnit", units: "stretch,start,end,center,space-between,space-around,space-evenly" }
    #    ) { text v_align }
    #  }
    #}

    #Wrapper(class: "panel-divider")

    ## Children Alignment
    #Header(size: 5) { text "Children Alignment" }

    #Wrapper(class: "sidebar-field") {
    #  Label { text "Horizontal" }
    #  Wrapper(class: "sidebar-input-row") {
    #    h_align = (@layout.config.dig("childrenAlignment", "horizontal")) || "stretch"
    #    Button(type: "button", id: "gridChildrenH", class: "unit-btn",
    #           data: { action: "click->page-editor#cycleUnit", units: "stretch,start,end,center" }
    #    ) { text h_align }
    #  }
    #}

    #Wrapper(class: "sidebar-field") {
    #  Label { text "Vertical" }
    #  Wrapper(class: "sidebar-input-row") {
    #    v_align = (@layout.config.dig("childrenAlignment", "vertical")) || "stretch"
    #    Button(type: "button", id: "gridChildrenV", class: "unit-btn",
    #           data: { action: "click->page-editor#cycleUnit", units: "stretch,start,end,center" }
    #    ) { text v_align }
    #  }
    #}
  }

  # --- Flex-specific fields ---
  #Wrapper(class: "flex-fields", data: { "page-editor-target": "flexFields" }, style: is_flex ? "" : "display:none;") {

  #  # Gap
  #  Wrapper(class: "sidebar-field") {
  #    Label(for: "flexGap") { text "Gap" }
  #    Wrapper(class: "sidebar-input-row") {
  #      Input(type: "text", id: "flexGap", value: @layout.config["gap"] || 16)
  #      Button(type: "button", id: "flexGapUnit", class: "unit-btn",
  #             data: { action: "click->page-editor#cycleUnit", units: "px,rem,%" }
  #      ) { text @layout.config["gapUnit"] || "px" }
  #    }
  #  }

  #  Wrapper(class: "panel-divider")

  #  # Direction
  #  Wrapper(class: "sidebar-field") {
  #    Label { text "Direction" }
  #    Wrapper(class: "sidebar-input-row") {
  #      direction = @layout.config["direction"] || "row"
  #      Button(type: "button", id: "flexDirection", class: "unit-btn",
  #             data: { action: "click->page-editor#cycleUnit", units: "row,column,row-reverse,column-reverse" }
  #      ) { text direction }
  #    }
  #  }

  #  # Wrap
  #  Wrapper(class: "sidebar-field") {
  #    Label { text "Wrap" }
  #    Wrapper(class: "sidebar-input-row") {
  #      wrap = @layout.config["wrap"] || "nowrap"
  #      Button(type: "button", id: "flexWrap", class: "unit-btn",
  #             data: { action: "click->page-editor#cycleUnit", units: "nowrap,wrap,wrap-reverse" }
  #      ) { text wrap }
  #    }
  #  }

  #  Wrapper(class: "panel-divider")

  #  # Container Alignment
  #  Header(size: 5) { text "Container Alignment" }

  #  Wrapper(class: "sidebar-field") {
  #    Label { text "Main Axis" }
  #    Wrapper(class: "sidebar-input-row") {
  #      main_axis = (@layout.config.dig("containerAlignment", "mainAxis")) || "flex-start"
  #      Button(type: "button", id: "flexMainAxis", class: "unit-btn",
  #             data: { action: "click->page-editor#cycleUnit", units: "flex-start,flex-end,center,space-between,space-around,space-evenly" }
  #      ) { text main_axis }
  #    }
  #  }

  #  Wrapper(class: "sidebar-field") {
  #    Label { text "Cross Axis" }
  #    Wrapper(class: "sidebar-input-row") {
  #      cross_axis = (@layout.config.dig("containerAlignment", "crossAxis")) || "stretch"
  #      Button(type: "button", id: "flexCrossAxis", class: "unit-btn",
  #             data: { action: "click->page-editor#cycleUnit", units: "stretch,flex-start,flex-end,center,baseline" }
  #      ) { text cross_axis }
  #    }
  #  }
  #}

  Wrapper(class: "panel-divider")

  Header(size: 5) { text "CSS" }
  Pre(data: { "page-editor-target": "cssOutput" }, class: "code-output")
  Header(size: 5) { text "HTML" }
  Pre(data: { "page-editor-target": "htmlOutput" }, class: "code-output")
  Header(size: 5) { text "JSON" }
  Pre(data: { "page-editor-target": "jsonOutput" }, class: "code-output")
}
