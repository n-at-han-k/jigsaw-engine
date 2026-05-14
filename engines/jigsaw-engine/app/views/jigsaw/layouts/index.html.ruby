Partial("jigsaw/layouts/_shared/menu")

Container(style: "padding: 1rem") {
  Header(size: :h2, dividing: true) { text "Layouts" }

  Table(celled: true, striped: true, rows: @layouts) { |c|
    c.column(:name, heading: "Name") { |layout|
      LinkTo(href: edit_layout_path(layout)) { text layout.name }
    }
    c.column(:tracks, heading: "Tracks") { |layout|
      cols = layout.config["columns"] || []
      rows = layout.config["rows"] || []
      text "#{cols.length}c x #{rows.length}r"
    }
    c.column(:actions, heading: "Actions") { |layout|
      LinkTo(href: edit_layout_path(layout), class: "ui mini blue button") { text "Edit" }
      ButtonTo(url: layout_path(layout), method: :delete, color: "red mini", confirm: "Delete this layout?") { text "Delete" }
    }
  }
}
