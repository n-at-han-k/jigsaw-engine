Partial("jigsaw/render_functions/_shared/menu")

Container(style: "padding: 1rem") {
  Header(size: :h2, dividing: true) { text "Render Functions" }

  Table(celled: true, striped: true, rows: @render_functions) { |c|
    c.column(:name, heading: "Name") { |func|
      LinkTo(href: edit_render_function_path(func)) { text func.name }
    }
    c.column(:language, heading: "Language") { |func|
      text func.language
    }
    c.column(:actions, heading: "Actions") { |func|
      LinkTo(href: edit_render_function_path(func), class: "ui mini blue button") { text "Edit" }
      ButtonTo(url: render_function_path(func), method: :delete, color: "red mini", confirm: "Delete this render function?") { text "Delete" }
    }
  }
}
