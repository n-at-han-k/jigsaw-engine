Partial("jigsaw/layouts/_shared/menu")

Container() {
  Header(size: :h2, dividing: true) { "Pages" }

  Table() { |c|

    c.header {
      TableRow {
        TableCell(heading: true) { "Title" }
        TableCell(heading: true) { "Path" }
        TableCell(heading: true) { "Layout" }
        TableCell(heading: true) { "Actions" }
      }
    }

    @pages.each do |page|
      TableRow {
        TableCell {
          LinkTo(href: edit_custom_page_path(page)) { text page.title }
        }

        TableCell {
          text "/#{page.path}"
        }

        TableCell {
          if page.layout
            text page.layout.name
          else
            text "—"
          end
        }

        TableCell {
          LinkTo(href: edit_custom_page_path(page), class: "ui mini blue button") { "Edit" }
        }
      }
    end

  }
}
