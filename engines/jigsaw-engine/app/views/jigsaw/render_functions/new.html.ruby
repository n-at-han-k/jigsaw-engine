Partial("jigsaw/render_functions/_shared/menu")

Container(style: "padding: 1rem") {
  Header(size: :h2, dividing: true) { text "New Render Function" }

  Form(url: render_functions_path, method: :post) {
    TextField(:name, required: true)
    Select(:language, [["JSX", "jsx"], ["JavaScript", "javascript"]])
    TextArea(:source)
    Submit("Create", color: "green")
  }
}
