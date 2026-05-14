Partial("jigsaw/layouts/_shared/menu")

Container(style: "padding: 1rem") {
  Header(size: :h2, dividing: true) { text "Layouts" }

  Table(celled: true, striped: true, rows: @layouts) { |c|
    c.column(:name, heading: "Name") { |layout|
      if layout.page
        LinkTo(href: edit_page_path(layout.page)) { text layout.name }
      else
        text layout.name
      end
    }
    c.column(:page, heading: "Page") { |layout|
      if layout.page
        text layout.page.title
      else
        text "—"
      end
    }
    c.column(:tracks, heading: "Tracks") { |layout|
      cols = layout.config["columns"] || []
      rows = layout.config["rows"] || []
      text "#{cols.length}c x #{rows.length}r"
    }
    c.column(:actions, heading: "Actions") { |layout|
      if layout.page
        LinkTo(href: edit_page_path(layout.page), class: "ui mini blue button") { text "Edit" }
      end
      ButtonTo(url: layout_path(layout), method: :delete, color: "red mini", confirm: "Delete this layout?") { text "Delete" }
    }
  }
}
