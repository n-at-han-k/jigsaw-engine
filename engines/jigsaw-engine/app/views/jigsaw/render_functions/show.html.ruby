Partial("jigsaw/render_functions/_shared/menu")

Container(style: "padding: 1rem") {
  Header(size: :h2, dividing: true) { text @render_function.name }

  Wrapper(class: "ui segment") {
    Header(size: 4) { text "Source (#{@render_function.language})" }
    Pre { Code { text @render_function.source } }
  }

  LinkTo(href: edit_render_function_path(@render_function), class: "ui blue button") { text "Edit" }
  ButtonTo(url: render_function_path(@render_function), method: :delete, color: "red", confirm: "Delete this render function?") { text "Delete" }
}
