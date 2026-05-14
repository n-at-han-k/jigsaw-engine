Partial("jigsaw/layouts/_shared/menu")

Container(style: "padding: 1rem") {
  Header(size: :h2, dividing: true) { text "New Layout" }

  Form(url: layouts_path, method: :post) {
    TextField(:name, required: true)
    Submit("Create", color: "green")
    LinkTo(href: layouts_path, class: "ui button") { text "Cancel" }
  }
}
