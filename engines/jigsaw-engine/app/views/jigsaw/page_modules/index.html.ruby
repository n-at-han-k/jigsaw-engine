Partial("jigsaw/page_modules/_shared/menu")

Container(style: "padding: 1rem") {
  Header(size: :h2, dividing: true) { text "Page Modules" }

  Table(celled: true, striped: true, rows: @page_modules) { |c|
    c.column(:id, heading: "ID") { |mod|
      LinkTo(href: edit_page_module_path(mod)) { text mod.id }
    }
    c.column(:slot, heading: "Slot") { |mod|
      text mod.slot || "—"
    }
    c.column(:position, heading: "Position") { |mod|
      text mod.position
    }
  }
}
