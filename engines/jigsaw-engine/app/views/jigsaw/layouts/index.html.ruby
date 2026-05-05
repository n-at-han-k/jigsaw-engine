Header(size: 2) { text "Layouts" }

Button(color: "green", tag: :a, href: new_layout_path) { text "New Layout" }

Table(celled: true, striped: true, rows: @layouts) { |c|
  c.column(:name, heading: "Name") { |layout|
    LinkTo(href: edit_layout_path(layout)) { text layout.name }
  }
  c.column(:type, heading: "Type") { |layout|
    text layout.config["type"]&.capitalize || "—"
  }
  c.column(:tracks, heading: "Tracks") { |layout|
    if layout.config["type"] == "grid"
      text "#{layout.config['columns']&.length || 0}c x #{layout.config['rows']&.length || 0}r"
    else
      text "#{layout.config['childrenCount'] || 0} children"
    end
  }
  c.column(:actions, heading: "Actions") { |layout|
    LinkTo(href: edit_layout_path(layout), class: "ui mini blue button") { text "Edit" }
    ButtonTo(url: layout_path(layout), method: :delete, color: "red mini", confirm: "Delete this layout?") { text "Delete" }
  }
}
