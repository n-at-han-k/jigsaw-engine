Container {
  Header(size: :h1) { text "Jigsaw Engine" }

  Wrapper(html_class: "ui cards") {
    Card(href: layouts_path, link: true) { |c|
      c.header { "Layouts" }
      c.description { "Manage page layouts and grid configurations" }
      nil
    }
    Card(href: data_functions_path, link: true) { |c|
      c.header { "Data Functions" }
      c.description { "Manage data-fetching functions" }
      nil
    }
    Card(href: render_functions_path, link: true) { |c|
      c.header { "Render Functions" }
      c.description { "Manage render functions" }
      nil
    }
    Card(href: page_modules_path, link: true) { |c|
      c.header { "Page Modules" }
      c.description { "View and edit page modules" }
      nil
    }
  }
}
