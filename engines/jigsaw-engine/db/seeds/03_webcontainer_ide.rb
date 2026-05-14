module Jigsaw
  SEEDS = Engine.root.join("app/javascript/seeds") unless defined?(SEEDS)

  IDE_CONFIG = {
    "type"    => "grid",
    "areas"   => [
      ["filetree", "editor",   "preview"],
      ["filetree", "terminal", "preview"]
    ],
    "columns" => ["220px", "1fr", "1fr"],
    "rows"    => ["1fr", "250px"],
    "gridWidth"  => "100vw",
    "gridHeight" => "100vh",
    "rowGap" => 0, "colGap" => 0,
    "rowGapUnit" => "px", "colGapUnit" => "px"
  }.freeze

  page = Page.find_or_initialize_by(path: "ide")
  page.title = "WebContainer IDE"
  page.save!

  layout = page.layout || page.build_layout
  layout.name = "IDE Layout"
  layout.config = IDE_CONFIG
  layout.save!
  layout.sync_slots

  SLOT_MAP = {
    "filetree" => "ide-file-tree",
    "editor"   => "ide-editor",
    "terminal" => "ide-terminal",
    "preview"  => "ide-preview",
  }.freeze

  SLOT_MAP.each do |area, seed_dir|
    config_data = JSON.parse(SEEDS.join("#{seed_dir}/config.json").read)
    shares = config_data.delete("shares") || []

    layout.slots.find_by!(area_name: area).update!(
      render_language: "jsx",
      shares: shares,
      config: config_data,
      data_source: SEEDS.join("#{seed_dir}/data.js").read,
      render_source: SEEDS.join("#{seed_dir}/render.jsx").read,
    )

    puts "[seeds] #{area} slot updated"
  end

  puts "[seeds] WebContainer IDE page created"
end
