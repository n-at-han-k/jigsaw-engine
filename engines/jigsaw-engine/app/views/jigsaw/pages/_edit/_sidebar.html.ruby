Wrapper() {

  Wrapper(class: "panel-divider")

  Header(size: 5) { text "CSS" }
  Pre(data: { "page-editor-target": "cssOutput" }, class: "code-output")
  Header(size: 5) { text "HTML" }
  Pre(data: { "page-editor-target": "htmlOutput" }, class: "code-output")
  Header(size: 5) { text "JSON" }
  Pre(data: { "page-editor-target": "jsonOutput" }, class: "code-output")
}
