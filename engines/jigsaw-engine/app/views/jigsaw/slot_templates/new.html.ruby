Menu(attached: "top") {
  BackButton(href: slot_templates_path, icon: "arrow left")
  MenuItem(header: true) { text "New Slot Template" }
}

Container(style: "padding: 1rem; max-width: 600px;") {
  Header(size: :h2, dividing: true) { text "Create a Slot Template" }

  Form(model: @slot_template, url: slot_templates_path, method: :post) {
    TextField(:name, required: true, placeholder: "My Slot Template", field: true)
    TextArea(:description, placeholder: "Optional description", field: true)
    TextField(:tag_list, placeholder: "marketing, hero, section (comma-separated)",
              field: true, value: @slot_template.tag_list.to_s,
              hint: "Tags for filtering and search")

    Wrapper(style: "margin-top: 1rem;") {
      Submit("Create", color: "green")
      LinkTo(href: slot_templates_path, css_class: "ui button") { text "Cancel" }
    }
  }
}
