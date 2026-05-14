Container {
  Header(size: :h1) { text "Jigsaw Engine" }

  Wrapper(html_class: "ui cards") {
    Card(href: pages_path, link: true) { |c|
      c.header { "Pages" }
      c.description { "Build and manage pages, layouts, and slot content" }
      nil
    }

    Card(href: layout_templates_path, link: true) { |c|
      c.header { "Layout Templates" }
      c.description { "Reusable grid layout structures" }
      nil
    }

    Card(href: slot_templates_path, link: true) { |c|
      c.header { "Slot Templates" }
      c.description { "Reusable slot content blocks with tags" }
      nil
    }
  }
}
