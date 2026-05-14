Form(model: @page, id: "page-form") {

  Wrapper(class: "sidebar-field") {
    Label(:title) { "Title" }
    Wrapper(class: "sidebar-input-row") {
      TextField(:title)
    }
  }

  Wrapper(class: "sidebar-field") {
    Label(:path) { "Path" }
    Wrapper(class: "sidebar-input-row") {
      TextField(:path)
    }
  }

  text hidden_field_tag("page[layout_attributes][id]", @layout.id)
  text hidden_field_tag(
    "page[layout_attributes][config]",
    @layout.config.to_json,
    id: "configHidden",
    data: { "layout-editor-target": "configHidden" }
  )

  FieldsFor(:layout) { |f|
    previous_form_builder = @_form_builder
    @_form_builder = f

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
        Button(type: "button", id: "rowGapUnit", class: "unit-btn",
               data: { action: "click->layout-editor#cycleUnit", units: "px,rem,%" }
        ) { @layout.rowGapUnit || "px" }
      }
    }

    Wrapper(class: "sidebar-field") {
      Label(:colGap) { "Column Gap" }
      Wrapper(class: "sidebar-input-row") {
        NumberField(:colGap, id: "colGap", min: 0, step: 1)
        Button(type: "button", id: "colGapUnit", class: "unit-btn",
               data: { action: "click->layout-editor#cycleUnit", units: "px,rem,%" }
        ) { @layout.colGapUnit || "px" }
      }
    }
  }
}
