Form(model: @layout_template, id: "layout-template-form") {

  Wrapper(class: "sidebar-field") {
    Label(:name) { "Name" }
    Wrapper(class: "sidebar-input-row") {
      TextField(:name)
    }
  }

  Wrapper(class: "sidebar-field") {
    Label(:description) { "Description" }
    Wrapper(class: "sidebar-input-row") {
      TextArea(:description, rows: 2)
    }
  }

  text hidden_field_tag(
    "layout_template[config]",
    @layout_template.config.to_json,
    id: "configHidden",
    data: { "layout-editor-target": "configHidden" }
  )

  Wrapper(class: "sidebar-field") {
    Label(:gridWidth) { "Width" }
    Wrapper(class: "sidebar-input-row") {
      TextField(:gridWidth, id: "gridWidth")
    }
  }

  Wrapper(class: "sidebar-field") {
    Label(:gridHeight) { "Height" }
    Wrapper(class: "sidebar-input-row") {
      TextField(:gridHeight, id: "gridHeight")
    }
  }

  Wrapper(class: "sidebar-field") {
    Label(:rowGap) { "Row Gap" }
    Wrapper(class: "sidebar-input-row") {
      NumberField(:rowGap, id: "rowGap", min: 0, step: 1)
      Button(
        type: "button",
        id: "rowGapUnit",
        class: "unit-btn",
        data: {
          action: "click->layout-editor#cycleUnit",
          units: "px,rem,%"
        }
      ) { @layout_template.rowGapUnit || "px" }
    }
  }

  Wrapper(class: "sidebar-field") {
    Label(:colGap) { "Column Gap" }
    Wrapper(class: "sidebar-input-row") {
      NumberField(:colGap, id: "colGap", min: 0, step: 1)
      Button(
        type: "button",
        id: "colGapUnit",
        class: "unit-btn",
        data: {
          action: "click->layout-editor#cycleUnit",
          units: "px,rem,%"
        }
      ) { @layout_template.colGapUnit || "px" }
    }
  }
}
