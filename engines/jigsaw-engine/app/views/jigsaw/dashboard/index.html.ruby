Container {
  Header(size: :h1) { text "Jigsaw Engine" }

  Wrapper(html_class: "ui cards") {
    Card(href: layouts_path, link: true) { |c|
      c.header { "Layouts" }
      c.description { "Manage page layouts and grid configurations" }
      nil
    }
    Card(href: pages_path, link: true) { |c|
      c.header { "Pages" }
      c.description { "Manage custom pages and their slots" }
      nil
    }
  }
}
