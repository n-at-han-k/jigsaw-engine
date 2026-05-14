StylesheetLink("jigsaw/layout_editor.css")

slot_id_by_area = @slots.each_with_object({}) { |s, h| h[s.area_name] = s.id }
slot_edit_paths = @slots.each_with_object({}) { |s, h| h[s.area_name] = edit_slot_path(s) }

Wrapper(
  data: {
    controller: "layout-editor",
    "layout-editor-slots-by-area-value": slot_id_by_area.to_json,
    "layout-editor-slot-edit-paths-value": slot_edit_paths.to_json
  }
) {

  Menu(attached: "top") {
    BackButton(href: pages_path, icon: "arrow left")

    SubMenu(position: "right") {
      if @layout&.linked_to_template?
        MenuItem {
          ButtonTo(
            url: unlink_template_page_path(@page),
            method: :post,
            color: "orange",
            size: "tiny",
            confirm: "Unlink from layout template? Grid config will be copied locally.",
            icon: "unlinkify"
          ) { "Unlink Layout" }
        }
      end

      MenuItem {
        Button(
          type: "button",
          icon: "sidebar",
          size: "tiny",
          data: { action: "click->layout-editor#togglePanel" }
        ) { "Panel" }
      }
      MenuItem {
        ButtonTo(
          url: page_path(@page),
          method: :delete,
          color: "red",
          size: "tiny",
          confirm: "Delete this page?",
          icon: "trash"
        ) { "Delete" }
      }

      unless @layout&.linked_to_template?
        MenuItem {
          Button(
            type: "submit",
            form: "page-form",
            color: "green",
            size: "tiny"
          ) { "Save" }
        }
      end
    }
  }

  if @layout&.linked_to_template?
    Message(info: true, style: "margin: 0.5rem 1rem;") {
      Wrapper(style: "display: flex; align-items: center; gap: 0.5em;") {
        text tag.i(class: "linkify icon")
        text "Layout linked to template: "
        text tag.strong(@layout.layout_template.name)
        text ". Grid editing is disabled."
      }
    }
  end

  Wrapper(class: "editor-page") {
    Wrapper(
      class: "editor-center",
      data: { "layout-editor-target": "preview" }
    )

    Wrapper(
      class: "editor-output",
      data: {
        "layout-editor-target": "panel",
        action: "input->layout-editor#rebuild"
      }
    ) {

      unless @layout&.linked_to_template?
        Partial("form")

        Wrapper(html_class: "panel-divider")
      end

      Header(size: 5) { "CSS" }
      Pre(data: { "layout-editor-target": "cssOutput" }, class: "code-output")

      Header(size: 5) { "HTML" }
      Pre(data: { "layout-editor-target": "htmlOutput" }, class: "code-output")

      Header(size: 5) { "JSON" }
      Pre(data: { "layout-editor-target": "jsonOutput" }, class: "code-output")
    }
  }
}
