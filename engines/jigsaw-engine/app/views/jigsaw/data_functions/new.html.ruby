Partial("jigsaw/data_functions/_shared/menu")

Container(style: "padding: 1rem") {
  Header(size: :h2, dividing: true) { text "New Data Function" }

  Form(url: data_functions_path, method: :post) {
    TextField(:name, required: true)
    TextArea(:source)
    Submit("Create", color: "green")
  }
}
