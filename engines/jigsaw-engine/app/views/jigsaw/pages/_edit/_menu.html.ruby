Menu(attached: "top") {

  BackButton(href: pages_path, icon: "arrow left")

  MenuItem(header: true) { @page.title }

  SubMenu(position: "right") {
    MenuItem(style: "padding: 0 8px;") {
      Button(
        icon: "exchange",
        size: "tiny",
        onclick: "$('.editor-page').toggle('show-tracks')"
      ) { "Tracks" }
    }

    MenuItem(style: "padding: 0 8px;") {
      Button(
        icon: "sidebar",
        size: "tiny",
        onclick: "$('.editor-page').toggle('show-sidebar')"
      ) { "Panel" }
    }

    MenuItem(style: "padding: 0 8px;") {
      Form(model: @page, html: {style: "margin: 0;"}) {
        HiddenField(
          :config,
          id: "configHidden",
          value: @layout.config.to_json,
          data: { "page-editor-target": "configHidden" }
        )

        Submit("Save", color: "green", size: "tiny")
      }
    }
  }
}
