Menu(attached: "top") {
  BackButton(href: root_path, icon: "arrow left")
  MenuItem(header: true) { text "Pages" }

  SubMenu(position: "right") {
    MenuItem(href: new_page_path, icon: "plus") { text "New Page" }
  }
}

Container(style: "padding: 1rem;") {
  Header(size: :h2, dividing: true) { "Pages" }

  if @pages.empty?
    Message(info: true) {
      text "No pages yet. "
      LinkTo(href: new_page_path) { text "Create your first page" }
      text "."
    }
  else
    Table() { |c|
      c.header {
        TableRow {
          TableCell(heading: true) { "Title" }
          TableCell(heading: true) { "Route" }
          TableCell(heading: true) { "Layout" }
          TableCell(heading: true) { "Layout Template" }
          TableCell(heading: true) { "Actions" }
        }
      }

      @pages.each do |page|
        TableRow {
          TableCell {
            LinkTo(href: edit_page_path(page)) { text page.title }
          }

          TableCell {
            LinkTo(href: custom_page_path(page), target: "_blank") { text "/#{page.path}" }
          }

          TableCell {
            text page.layout ? page.layout.name : "—"
          }

          TableCell {
            if page.layout&.linked_to_template? && page.layout.layout_template
              Wrapper(style: "display: flex; align-items: center; gap: 0.3em;") {
                text tag.i(class: "linkify icon")
                text page.layout.layout_template.name
              }
            else
              text "—"
            end
          }

          TableCell {
            LinkTo(href: edit_page_path(page), css_class: "ui mini blue button") { "Edit" }
            ButtonTo(url: page_path(page), method: :delete, color: "red mini",
                     confirm: "Delete this page?") { text "Delete" }
          }
        }
      end
    }
  end
}
