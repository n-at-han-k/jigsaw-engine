Menu(attached: "top") {
  BackButton(href: layout_templates_path, icon: "arrow left")
  MenuItem(header: true) { text "New Layout Template" }
}

Container(style: "padding: 1rem; max-width: 600px;") {
  Header(size: :h2, dividing: true) { text "Create a Layout Template" }

  Form(model: @layout_template, url: layout_templates_path, method: :post) {
    TextField(:name, required: true, placeholder: "My Layout Template", field: true)
    TextArea(:description, placeholder: "Optional description", field: true)
    TextField(:thumbnail, placeholder: "URL or path to thumbnail (optional)", field: true)

    Wrapper(style: "margin-top: 1rem;") {
      Submit("Create", color: "green")
      LinkTo(href: layout_templates_path, css_class: "ui button") { text "Cancel" }
    }
  }
}
