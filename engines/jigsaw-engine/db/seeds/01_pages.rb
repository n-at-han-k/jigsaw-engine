module Jigsaw
  HOLY_GRAIL_CONFIG = {
    "type"        => "grid",
    "areas"       => [
      ["header", "header", "header"],
      ["left",   "main",   "right"],
      ["footer", "footer", "footer"]
    ],
    "columns"     => ["120px", "4fr", "1fr"],
    "rows"        => ["80px", "1fr", "60px"],
    "gridWidth"   => "100%",
    "gridHeight"  => "100%",
    "rowGap"      => 8,
    "colGap"      => 8,
    "rowGapUnit"  => "px",
    "colGapUnit"  => "px"
  }.freeze

  SIMPLE_CONFIG = {
    "type"        => "grid",
    "areas"       => [["main"]],
    "columns"     => ["1fr"],
    "rows"        => ["1fr"],
    "gridWidth"   => "100%",
    "gridHeight"  => "100%",
    "rowGap"      => 0,
    "colGap"      => 0,
    "rowGapUnit"  => "px",
    "colGapUnit"  => "px"
  }.freeze

  TWO_COL_CONFIG = {
    "type"        => "grid",
    "areas"       => [
      ["header", "header"],
      ["sidebar", "content"],
      ["footer", "footer"]
    ],
    "columns"     => ["240px", "1fr"],
    "rows"        => ["80px", "1fr", "60px"],
    "gridWidth"   => "100%",
    "gridHeight"  => "100%",
    "rowGap"      => 12,
    "colGap"      => 12,
    "rowGapUnit"  => "px",
    "colGapUnit"  => "px"
  }.freeze

  PAGE_DATA = [
    { title: "Home",       path: "home",       config: HOLY_GRAIL_CONFIG },
    { title: "About",      path: "about",      config: TWO_COL_CONFIG },
    { title: "Blog",       path: "blog",       config: TWO_COL_CONFIG },
    { title: "Contact",    path: "contact",    config: SIMPLE_CONFIG }
  ]

  PAGE_DATA.each do |attrs|
    page = Page.find_or_initialize_by(path: attrs[:path])
    page.title = attrs[:title]
    page.save!

    layout = page.layout || page.build_layout
    layout.name = "#{page.title} Layout"
    layout.config = attrs[:config]
    layout.save!
    layout.sync_slots
  end

  puts "[seeds] Pages: #{Page.count}, Layouts: #{Layout.count}, Slots: #{Slot.count}"
end
