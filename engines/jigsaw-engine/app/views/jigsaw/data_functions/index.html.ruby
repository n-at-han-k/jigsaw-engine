Partial("jigsaw/data_functions/_shared/menu")

Container(style: "padding: 1rem") {
  Header(size: :h2, dividing: true) { text "Data Functions" }

  Table(celled: true, striped: true, rows: @data_functions) { |c|
    c.column(:name, heading: "Name") { |func|
      LinkTo(href: edit_data_function_path(func)) { text func.name }
    }
    c.column(:language, heading: "Language") { |func|
      text func.language
    }
    c.column(:actions, heading: "Actions") { |func|
      LinkTo(href: edit_data_function_path(func), class: "ui mini blue button") { text "Edit" }
      ButtonTo(url: data_function_path(func), method: :delete, color: "red mini", confirm: "Delete this data function?") { text "Delete" }
    }
  }
}
