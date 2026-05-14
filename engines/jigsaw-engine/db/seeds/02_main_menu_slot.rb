module Jigsaw
  SEEDS = Engine.root.join("app/javascript/seeds")

  home = Page.find_by!(path: "home")
  slot = home.layout.slots.find_by!(area_name: "header")

  slot.update!(
    render_language: "jsx",
    config: JSON.parse(SEEDS.join("main-menu/config.json").read),
    data_source: SEEDS.join("main-menu/data.js").read,
    render_source: SEEDS.join("main-menu/render.jsx").read,
  )

  puts "[seeds] Main menu slot updated: ##{slot.id} (#{slot.area_name})"
end
