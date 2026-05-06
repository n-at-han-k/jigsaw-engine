Menu(attached: "top") {
  BackButton(href: root_path, icon: "arrow left")

  MenuItem(header: true) {
    text @data_function&.persisted? ? @data_function.name : "Data Functions"
  }

  SubMenu(position: "right") {
    if @data_function&.persisted?
      MenuItem(href: edit_data_function_path(@data_function), icon: "edit") { text "Edit" }
    end
    MenuItem(href: new_data_function_path, icon: "plus") { text "New" }
  }
}
