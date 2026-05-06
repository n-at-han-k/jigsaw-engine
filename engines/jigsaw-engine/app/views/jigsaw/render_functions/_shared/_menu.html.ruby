Menu(attached: "top") {
  BackButton(href: root_path, icon: "arrow left")

  MenuItem(header: true) {
    text @render_function&.persisted? ? @render_function.name : "Render Functions"
  }

  SubMenu(position: "right") {
    if @render_function&.persisted?
      MenuItem(href: edit_render_function_path(@render_function), icon: "edit") { text "Edit" }
    end
    MenuItem(href: new_render_function_path, icon: "plus") { text "New" }
  }
}
