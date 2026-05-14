Menu(attached: "top") {
  BackButton(href: root_path, icon: "arrow left")

  MenuItem(header: true) {
    text @layout&.persisted? ? @layout.name : "Layouts"
  }

  SubMenu(position: "right") {
    if @layout&.persisted? && @layout.page
      MenuItem(href: edit_page_path(@layout.page), icon: "edit") { text "Edit" }
    end
    MenuItem(href: new_layout_path, icon: "plus") { text "New" }
  }
}
