Header(size: 2) { text "New Layout" }

Form(url: layouts_path, method: :post, class: "ui form") {
  Wrapper(class: "field") {
    Label { text "Name" }
    Input(type: "text", name: "layout[name]", required: true, placeholder: "e.g. three-column, dashboard")
  }

  Wrapper(class: "grouped fields") {
    Label { text "Type" }
    Wrapper(class: "field") {
      Wrapper(class: "ui radio checkbox") {
        Input(type: "radio", name: "layout[config][type]", value: "grid", checked: true)
        Label { text "CSS Grid" }
      }
    }
    Wrapper(class: "field") {
      Wrapper(class: "ui radio checkbox") {
        Input(type: "radio", name: "layout[config][type]", value: "flex")
        Label { text "Flexbox" }
      }
    }
  }

  Button(type: "submit", color: "green") { text "Create" }
  LinkTo(href: layouts_path, class: "ui button") { text "Cancel" }
}
