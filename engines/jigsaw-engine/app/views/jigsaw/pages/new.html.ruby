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

    if @layout_templates.any?
      Wrapper(class: "field") {
        text label_tag("page_layout_template_id", "Layout Template (optional)")
        text select_tag(
          "page[layout_template_id]",
          options_from_collection_for_select(@layout_templates, :id, :name),
          include_blank: "— No template (blank layout) —",
          class: "ui dropdown"
        )
        Wrapper(style: "margin-top: 0.25em; font-size: 0.85em; color: #666;") {
          text "Selecting a layout template links this page's grid structure to the template."
        }
      }
    end

    Wrapper(style: "margin-top: 1rem;") {
      Submit("Create", color: "green")
      LinkTo(href: pages_path, css_class: "ui button") { text "Cancel" }
    }
  }
}
