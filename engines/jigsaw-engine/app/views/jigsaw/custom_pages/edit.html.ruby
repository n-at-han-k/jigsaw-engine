StylesheetLink("jigsaw/layout_editor.css")

# NOTE: no idea what all this shite is....
#initial_style = if @layout.config["type"] == "flex"
#  c = @layout.config
#  parts = ["display: flex", "width: 100%"]
#  parts << "gap: #{c['gap'] || 16}#{c['gapUnit'] || 'px'}"
#  parts << "flex-direction: #{c['direction']}" if c["direction"] && c["direction"] != "row"
#  parts << "flex-wrap: #{c['wrap']}" if c["wrap"] && c["wrap"] != "nowrap"
#  parts.join("; ")
#else
#  c = @layout.config
#  rows = c["rows"] || []
#  cols = c["columns"] || []
#  parts = ["display: grid", "width: 100%"]
#
#  row_str = if rows.is_a?(Array)
#    rows.map { |t| t["unit"] == "auto" ? "auto" : "#{t['value']}#{t['unit']}" }.join(" ")
#  elsif rows.is_a?(Hash) && rows["repeat"]
#    size = rows["unit"] == "auto" ? "auto" : "#{rows['value']}#{rows['unit']}"
#    "repeat(#{rows['repeat']}, #{size})"
#  else
#    "1fr"
#  end
#
#  col_str = if cols.is_a?(Array)
#    cols.map { |t| t["unit"] == "auto" ? "auto" : "#{t['value']}#{t['unit']}" }.join(" ")
#  else
#    "1fr"
#  end
#
#  parts << "grid-template-rows: #{row_str}"
#  parts << "grid-template-columns: #{col_str}"
#
#  row_gap = "#{c['rowGap'] || 8}#{c['rowGapUnit'] || 'px'}"
#  col_gap = "#{c['colGap'] || 8}#{c['colGapUnit'] || 'px'}"
#  parts << "gap: #{row_gap} #{col_gap}"
#
#  if c["areas"].is_a?(Array) && c["areas"].any?
#    areas_str = c["areas"].map { |row| "\"#{row.join(' ')}\"" }.join(" ")
#    parts << "grid-template-areas: #{areas_str}"
#  end
#
#  parts.join("; ")
#end

Wrapper(data: { controller: "page-editor" }) {
  Partial("jigsaw/custom_pages/_edit/menu")

  Wrapper(class: "editor-page") {
    Wrapper(class: "editor-center") {

      Wrapper(
        class: "track-controls track-controls--col",
        data: { "page-editor-target": "colTrackControls" }
      )

      Wrapper(class: "preview-main") {
        Wrapper(
          class: "preview-grid",
          #style: initial_style,
          data: {
            controller: "custom-page",
            "custom-page-page-id-value": @page.id,
            "page-editor-target": "grid"
          }
        ) {

          @modules.each { Partial("jigsaw/custom_pages/_edit/module", page_module: _1) }
        }
      }

      Wrapper(
        class: "track-controls track-controls--row",
        data: { "page-editor-target": "rowTrackControls" }
      )
    }

    Partial("jigsaw/custom_pages/_edit/sidebar")
  }
}

