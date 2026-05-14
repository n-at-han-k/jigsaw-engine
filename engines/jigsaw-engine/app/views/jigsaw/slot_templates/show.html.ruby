Menu(attached: "top") {
  BackButton(href: slot_templates_path, icon: "arrow left")
  MenuItem(header: true) { text @slot_template.name }

  SubMenu(position: "right") {
    MenuItem(href: edit_slot_template_path(@slot_template), icon: "edit") { text "Edit" }
    MenuItem {
      ButtonTo(url: slot_template_path(@slot_template), method: :delete, color: "red mini",
               confirm: "Delete this slot template?") { text "Delete" }
    }
  }
}

Container(style: "padding: 1rem;") {
  if @slot_template.description.present?
    Wrapper(style: "margin-bottom: 1em; color: #666;") {
      text @slot_template.description
    }
  end

  if @slot_template.tag_list.any?
    Wrapper(style: "margin-bottom: 1em;") {
      @slot_template.tag_list.each do |tag_name|
        LinkTo(href: slot_templates_path(tag: tag_name), css_class: "ui mini label") { text tag_name }
      end
    }
  end

  Header(size: 4) { "Data Source" }
  Pre(style: "background: #1e1e1e; color: #d4d4d4; padding: 1em; border-radius: 4px; overflow-x: auto;") {
    text @slot_template.data_source || "(empty)"
  }

  Header(size: 4) { "Render Source (#{@slot_template.render_language})" }
  Pre(style: "background: #1e1e1e; color: #d4d4d4; padding: 1em; border-radius: 4px; overflow-x: auto;") {
    text @slot_template.render_source || "(empty)"
  }
}
