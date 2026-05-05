# --- Layout Templates ---

Jigsaw::Layout.find_or_create_by!(name: "12 Span Grid") do |l|
  l.config = {
    "type" => "grid",
    "childrenCount" => 4,
    "rows" => [
      { "value" => 1, "unit" => "fr" },
      { "value" => 1, "unit" => "fr" },
      { "value" => 1, "unit" => "fr" },
      { "value" => 1, "unit" => "fr" }
    ],
    "columns" => [
      { "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" },
      { "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" },
      { "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" },
      { "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" },
      { "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" },
      { "value" => 1, "unit" => "fr" }, { "value" => 1, "unit" => "fr" }
    ],
    "rowGap" => 8, "rowGapUnit" => "px",
    "colGap" => 8, "colGapUnit" => "px",
    "direction" => "row",
    "emptySpace" => "dont-fill",
    "containerAlignment" => { "horizontal" => "stretch", "vertical" => "stretch" },
    "childrenAlignment" => { "horizontal" => "stretch", "vertical" => "stretch" },
    "areas" => [
      %w[span12 span12 span12 span12 span12 span12 span12 span12 span12 span12 span12 span12],
      %w[span6 span6 span6 span6 span6 span6 . . . . . .],
      %w[. . . . . span3 span3 span3 . . . .],
      %w[. . . . span1 . . . . . . .]
    ]
  }
end

Jigsaw::Layout.find_or_create_by!(name: "3 x 3") do |l|
  l.config = {
    "type" => "grid",
    "childrenCount" => 9,
    "rows" => [
      { "value" => 1, "unit" => "fr" },
      { "value" => 1, "unit" => "fr" },
      { "value" => 1, "unit" => "fr" }
    ],
    "columns" => [
      { "value" => 1, "unit" => "fr" },
      { "value" => 1, "unit" => "fr" },
      { "value" => 1, "unit" => "fr" }
    ],
    "rowGap" => 8, "rowGapUnit" => "px",
    "colGap" => 8, "colGapUnit" => "px",
    "direction" => "row",
    "emptySpace" => "dont-fill",
    "containerAlignment" => { "horizontal" => "stretch", "vertical" => "stretch" },
    "childrenAlignment" => { "horizontal" => "stretch", "vertical" => "stretch" }
  }
end

Jigsaw::Layout.find_or_create_by!(name: "Holy Grail") do |l|
  l.config = {
    "type" => "grid",
    "childrenCount" => 5,
    "rows" => [
      { "value" => 1, "unit" => "auto" },
      { "value" => 1, "unit" => "fr" },
      { "value" => 1, "unit" => "auto" }
    ],
    "columns" => [
      { "value" => 1, "unit" => "auto" },
      { "value" => 1, "unit" => "fr" },
      { "value" => 1, "unit" => "auto" }
    ],
    "rowGap" => 8, "rowGapUnit" => "px",
    "colGap" => 8, "colGapUnit" => "px",
    "direction" => "row",
    "emptySpace" => "dont-fill",
    "containerAlignment" => { "horizontal" => "stretch", "vertical" => "stretch" },
    "childrenAlignment" => { "horizontal" => "stretch", "vertical" => "stretch" },
    "areas" => [
      %w[header header header],
      %w[leftSide body rightSide],
      %w[footer footer footer]
    ]
  }
end

Jigsaw::Layout.find_or_create_by!(name: "Sidebar") do |l|
  l.config = {
    "type" => "grid",
    "childrenCount" => 2,
    "rows" => [
      { "value" => 1, "unit" => "fr" }
    ],
    "columns" => [
      { "value" => 1, "unit" => "auto" },
      { "value" => 1, "unit" => "fr" }
    ],
    "rowGap" => 8, "rowGapUnit" => "px",
    "colGap" => 8, "colGapUnit" => "px",
    "direction" => "row",
    "emptySpace" => "dont-fill",
    "containerAlignment" => { "horizontal" => "stretch", "vertical" => "stretch" },
    "childrenAlignment" => { "horizontal" => "stretch", "vertical" => "stretch" },
    "areas" => [
      %w[sidebar body]
    ]
  }
end

Jigsaw::Layout.find_or_create_by!(name: "Header Main Footer") do |l|
  l.config = {
    "type" => "grid",
    "childrenCount" => 3,
    "rows" => [
      { "value" => 1, "unit" => "auto" },
      { "value" => 1, "unit" => "fr" },
      { "value" => 1, "unit" => "auto" }
    ],
    "columns" => [
      { "value" => 1, "unit" => "fr" }
    ],
    "rowGap" => 8, "rowGapUnit" => "px",
    "colGap" => 8, "colGapUnit" => "px",
    "direction" => "row",
    "emptySpace" => "dont-fill",
    "containerAlignment" => { "horizontal" => "stretch", "vertical" => "stretch" },
    "childrenAlignment" => { "horizontal" => "stretch", "vertical" => "stretch" },
    "areas" => [
      %w[header],
      %w[main],
      %w[footer]
    ]
  }
end

Jigsaw::Layout.find_or_create_by!(name: "Infinite Rows") do |l|
  l.config = {
    "type" => "grid",
    "childrenCount" => 12,
    "rows" => { "repeat" => "auto-fit", "value" => 1, "unit" => "fr" },
    "columns" => [
      { "value" => 1, "unit" => "fr" },
      { "value" => 1, "unit" => "fr" },
      { "value" => 1, "unit" => "fr" }
    ],
    "rowGap" => 8, "rowGapUnit" => "px",
    "colGap" => 8, "colGapUnit" => "px",
    "direction" => "row",
    "emptySpace" => "dont-fill",
    "containerAlignment" => { "horizontal" => "stretch", "vertical" => "stretch" },
    "childrenAlignment" => { "horizontal" => "stretch", "vertical" => "stretch" }
  }
end

Jigsaw::Layout.find_or_create_by!(name: "Infinite Rows with Areas") do |l|
  l.config = {
    "type" => "grid",
    "childrenCount" => 6,
    "rows" => { "repeat" => "auto-fill", "value" => 1, "unit" => "fr" },
    "columns" => [
      { "value" => 1, "unit" => "fr" },
      { "value" => 1, "unit" => "fr" },
      { "value" => 1, "unit" => "fr" }
    ],
    "rowGap" => 8, "rowGapUnit" => "px",
    "colGap" => 8, "colGapUnit" => "px",
    "gridAreasMode" => "line numbers",
    "direction" => "row",
    "emptySpace" => "dont-fill",
    "containerAlignment" => { "horizontal" => "stretch", "vertical" => "stretch" },
    "childrenAlignment" => { "horizontal" => "stretch", "vertical" => "stretch" },
    "childPlacements" => [
      {},
      { "column" => "1 / -1" },
      { "column" => "1 / -1" },
      {},
      { "column" => "1 / -1" },
      { "column" => "1 / -1" }
    ]
  }
end

Jigsaw::Layout.find_or_create_by!(name: "Row") do |l|
  l.config = {
    "type" => "flex",
    "childrenCount" => 3,
    "gap" => 16, "gapUnit" => "px",
    "direction" => "row",
    "wrap" => "nowrap",
    "containerAlignment" => { "mainAxis" => "flex-start", "crossAxis" => "stretch" },
    "children" => [
      { "grow" => 0, "shrink" => 1, "basis" => "auto", "margin" => false },
      { "grow" => 0, "shrink" => 1, "basis" => "auto", "margin" => false },
      { "grow" => 0, "shrink" => 1, "basis" => "auto", "margin" => false }
    ]
  }
end

Jigsaw::Layout.find_or_create_by!(name: "Row Wrap") do |l|
  l.config = {
    "type" => "flex",
    "childrenCount" => 11,
    "gap" => 16, "gapUnit" => "px",
    "direction" => "row",
    "wrap" => "wrap",
    "containerAlignment" => { "mainAxis" => "flex-start", "crossAxis" => "stretch" },
    "children" => Array.new(11) { { "grow" => 0, "shrink" => 1, "basis" => "auto", "margin" => false } }
  }
end

Jigsaw::Layout.find_or_create_by!(name: "Fill Space") do |l|
  l.config = {
    "type" => "flex",
    "childrenCount" => 3,
    "gap" => 16, "gapUnit" => "px",
    "direction" => "row",
    "wrap" => "nowrap",
    "containerAlignment" => { "mainAxis" => "flex-start", "crossAxis" => "stretch" },
    "children" => [
      { "grow" => 1, "shrink" => 1, "basis" => "auto", "margin" => false },
      { "grow" => 1, "shrink" => 1, "basis" => "auto", "margin" => false },
      { "grow" => 1, "shrink" => 1, "basis" => "auto", "margin" => false }
    ]
  }
end

Jigsaw::Layout.find_or_create_by!(name: "Fill Remaining Space") do |l|
  l.config = {
    "type" => "flex",
    "childrenCount" => 3,
    "gap" => 16, "gapUnit" => "px",
    "direction" => "row",
    "wrap" => "nowrap",
    "containerAlignment" => { "mainAxis" => "flex-start", "crossAxis" => "stretch" },
    "children" => [
      { "grow" => 0, "shrink" => 1, "basis" => "auto", "margin" => false },
      { "grow" => 0, "shrink" => 1, "basis" => "auto", "margin" => false },
      { "grow" => 1, "shrink" => 1, "basis" => "auto", "margin" => false }
    ]
  }
end

Jigsaw::Layout.find_or_create_by!(name: "Push Right") do |l|
  l.config = {
    "type" => "flex",
    "childrenCount" => 3,
    "gap" => 16, "gapUnit" => "px",
    "direction" => "row",
    "wrap" => "nowrap",
    "containerAlignment" => { "mainAxis" => "flex-start", "crossAxis" => "stretch" },
    "children" => [
      { "grow" => 0, "shrink" => 1, "basis" => "auto", "margin" => false },
      { "grow" => 0, "shrink" => 1, "basis" => "auto", "margin" => false },
      { "grow" => 0, "shrink" => 1, "basis" => "auto", "margin" => true }
    ]
  }
end

# --- Custom Page + Module Demo ---

data_fn = Jigsaw::DataFunction.find_or_create_by!(name: "hello_data") do |f|
  f.source = <<~JS
    export default async function(shared, config) {
      return { message: config.greeting || "Hello from Jigsaw!", timestamp: new Date().toISOString() }
    }
  JS
end

render_fn = Jigsaw::RenderFunction.find_or_create_by!(name: "hello_render") do |f|
  f.language = "javascript"
  f.source = <<~JS
    export default function(data) {
      this.element.innerHTML = `
        <div style="padding: 1em; border: 1px solid #ccc; border-radius: 4px; margin: 1em 0;">
          <h3>${data.message}</h3>
          <p>Rendered at ${data.timestamp}</p>
        </div>
      `
    }
  JS
end

jsx_render_fn = Jigsaw::RenderFunction.find_or_create_by!(name: "hello_jsx_render") do |f|
  f.language = "jsx"
  f.source = <<~JS
    import { createRoot } from "react-dom/client"

    export default function(data) {
      if (!this.reactRoot) {
        this.reactRoot = createRoot(this.element)
      }
      this.reactRoot.render(
        <div style={{ padding: "1em", border: "1px solid #4a9eff", borderRadius: "4px", margin: "1em 0" }}>
          <h3>{data.message}</h3>
          <p>Rendered with React at {data.timestamp}</p>
        </div>
      )
    }
  JS
end

page = Jigsaw::CustomPage.find_or_create_by!(path: "dashboards/example") do |p|
  p.title = "Example Dashboard"
end

Jigsaw::PageModule.find_or_create_by!(custom_page: page, data_function: data_fn, render_function: render_fn) do |m|
  m.position = 0
  m.config = { greeting: "Hello, world!" }
end

Jigsaw::PageModule.find_or_create_by!(custom_page: page, data_function: data_fn, render_function: jsx_render_fn) do |m|
  m.position = 1
  m.config = { greeting: "Hello from JSX!" }
end
