Menu(attached: "top") {
  BackButton(href: root_path, icon: "arrow left")
  MenuItem(header: true) { text "Layout Templates" }

  SubMenu(position: "right") {
    MenuItem(href: new_layout_template_path, icon: "plus") { text "New Layout Template" }
  }
}

Container(style: "padding: 1rem;") {
  Header(size: :h2, dividing: true) { "Layout Templates" }

  if @layout_templates.empty?
    Message(info: true) {
      text "No layout templates yet. "
      LinkTo(href: new_layout_template_path) { text "Create your first layout template" }
      text "."
    }
  else
    Table() { |c|
      c.header {
        TableRow {
          TableCell(heading: true) { "Name" }
          TableCell(heading: true) { "Description" }
          TableCell(heading: true) { "Actions" }
        }
      }

      @layout_templates.each do |lt|
        TableRow {
          TableCell {
            LinkTo(href: edit_layout_template_path(lt)) { text lt.name }
          }

          TableCell {
            text lt.description || "—"
          }

          TableCell {
            LinkTo(href: edit_layout_template_path(lt), css_class: "ui mini blue button") { "Edit" }
            ButtonTo(url: layout_template_path(lt), method: :delete, color: "red mini",
                     confirm: "Delete this layout template?") { text "Delete" }
          }
        }
      end
    }
  end
}
