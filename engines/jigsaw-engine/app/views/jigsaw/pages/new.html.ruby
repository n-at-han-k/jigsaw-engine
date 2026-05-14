Menu(attached: "top") {
  BackButton(href: pages_path, icon: "arrow left")
  MenuItem(header: true) { text "New Page" }
}

Container(style: "padding: 1rem; max-width: 600px;") {
  Header(size: :h2, dividing: true) { text "Create a Page" }

  Form(model: @page, url: pages_path, method: :post) {
    TextField(:title, required: true, placeholder: "My New Page", field: true)
    TextField(:path, required: true, placeholder: "blog/hello-world",
              hint: "URL path under /jigsaw/ (no leading slash)", field: true)

    Wrapper(style: "margin-top: 1rem;") {
      Submit("Create", color: "green")
      LinkTo(href: pages_path, css_class: "ui button") { text "Cancel" }
    }
  }
}
