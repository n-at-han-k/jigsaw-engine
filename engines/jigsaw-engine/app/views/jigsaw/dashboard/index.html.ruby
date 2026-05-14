Container {
  Header(size: :h1) { text "Jigsaw Engine" }

  Wrapper(html_class: "ui cards") {
    Card(href: pages_path, link: true) { |c|
      c.header { "Pages" }
      c.description { "Build and manage pages, layouts, and slot content" }
      nil
    }
  }
}
