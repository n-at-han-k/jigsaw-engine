Partial("jigsaw/slots/_shared/menu")

Container(style: "padding: 1rem") {
  Header(size: :h2, dividing: true) { text "Slots" }

  Table(celled: true, striped: true, rows: @slots) { |c|
    c.column(:id, heading: "ID") { |slot|
      LinkTo(href: edit_slot_path(slot)) { text slot.id }
    }
    c.column(:area_name, heading: "Area") { |slot|
      text slot.area_name || "—"
    }
    c.column(:position, heading: "Position") { |slot|
      text slot.position
    }
  }
}
