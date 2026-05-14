Menu(attached: "top") {
  BackButton(href: root_path, icon: "arrow left")
  MenuItem(header: true) { text "Slot Templates" }

  SubMenu(position: "right") {
    MenuItem(href: new_slot_template_path, icon: "plus") { text "New Slot Template" }
  }
}

Container(style: "padding: 1rem;") {
  Header(size: :h2, dividing: true) { "Slot Templates" }

  # Tag filter
  if @tags.any?
    Wrapper(style: "margin-bottom: 1rem;") {
      if params[:tag].present?
        LinkTo(href: slot_templates_path, css_class: "ui mini button") { text "All" }
      else
        LinkTo(href: slot_templates_path, css_class: "ui mini button active") { text "All" }
      end

      @tags.each do |tag|
        css = params[:tag] == tag.name ? "ui mini blue button" : "ui mini button"
        LinkTo(href: slot_templates_path(tag: tag.name), css_class: css) {
          text "#{tag.name} (#{tag.taggings_count})"
        }
      end
    }
  end

  if @slot_templates.empty?
    Message(info: true) {
      text "No slot templates found. "
      LinkTo(href: new_slot_template_path) { text "Create your first slot template" }
      text "."
    }
  else
    Table() { |c|
      c.header {
        TableRow {
          TableCell(heading: true) { "Name" }
          TableCell(heading: true) { "Tags" }
          TableCell(heading: true) { "Language" }
          TableCell(heading: true) { "Actions" }
        }
      }

      @slot_templates.each do |st|
        TableRow {
          TableCell {
            LinkTo(href: edit_slot_template_path(st)) { text st.name }
          }

          TableCell {
            st.tag_list.each do |tag_name|
              LinkTo(href: slot_templates_path(tag: tag_name), css_class: "ui mini label") { text tag_name }
            end
          }

          TableCell {
            text st.render_language
          }

          TableCell {
            LinkTo(href: edit_slot_template_path(st), css_class: "ui mini blue button") { "Edit" }
            ButtonTo(url: slot_template_path(st), method: :delete, color: "red mini",
                     confirm: "Delete this slot template?") { text "Delete" }
          }
        }
      end
    }
  end
}
