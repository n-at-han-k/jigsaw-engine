# frozen_string_literal: true

class CustomModuleComponent < Component
  attribute :module_id,          :integer
  attribute :data_function_url,  :string
  attribute :render_function_url, :string
  attribute :config,             :string, default: "{}"
  attribute :shares,             :string, default: "[]"
  attribute :edit_url,           :string

  def to_s
    toolbar = tag.div(style: "position: absolute; top: 4px; right: 4px; z-index: 10;") {
      tag.button(
        class: "ui mini icon button",
        type: "button",
        onclick: "$('.ui.flyout').flyout('show'); document.querySelector('#editor').src = '#{edit_url}'"
      ) {
        tag.i(class: "pencil icon")
      }
    }

    content = tag.div(
      data: {
        controller: "custom-module",
        "custom-module-id-value": module_id,
        "custom-module-data-fn-url-value": data_function_url,
        "custom-module-render-fn-url-value": render_function_url,
        "custom-module-config-value": config,
        "custom-module-shares-value": shares
      },
      class: "custom-module-content"
    )

    tag.div(**merge_html_options(style: "position: relative;")) {
      safe_join([toolbar, content])
    }
  end
end
