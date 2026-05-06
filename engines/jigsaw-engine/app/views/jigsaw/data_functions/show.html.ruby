Partial("jigsaw/data_functions/_shared/menu")

Container(style: "padding: 1rem") {
  Header(size: :h2, dividing: true) { text @data_function.name }

  Wrapper(class: "ui segment") {
    Header(size: 4) { text "Source" }
    Pre { Code { text @data_function.source } }
  }

  LinkTo(href: edit_data_function_path(@data_function), class: "ui blue button") { text "Edit" }
  ButtonTo(url: data_function_path(@data_function), method: :delete, color: "red", confirm: "Delete this data function?") { text "Delete" }
}
