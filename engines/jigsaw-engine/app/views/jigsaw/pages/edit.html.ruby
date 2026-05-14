StylesheetLink("jigsaw/layout_editor.css")

Wrapper(data: { controller: "page-editor" }) {
  Partial("jigsaw/pages/_edit/menu")

  Wrapper(class: "editor-page") {
    Wrapper(class: "editor-center") {

      Wrapper(
        class: "track-controls track-controls--col",
        data: { "page-editor-target": "colTrackControls" }
      )

      Wrapper(class: "preview-main") {
        Wrapper(
          class: "preview-grid",
          data: {
            controller: "custom-page",
            "custom-page-page-id-value": @page.id,
            "page-editor-target": "grid"
          }
        ) {

          @slots.each { |slot| Partial("jigsaw/pages/_edit/slot", slot: slot) }
        }
      }

      Wrapper(
        class: "track-controls track-controls--row",
        data: { "page-editor-target": "rowTrackControls" }
      )
    }

    Partial("jigsaw/pages/_edit/sidebar")
  }
}
