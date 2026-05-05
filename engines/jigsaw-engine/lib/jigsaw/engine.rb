require "jigsaw/version"
require "jigsaw/jsx_compiler"
require "jigsaw/grid_layout_generator"
require "jigsaw/flex_layout_generator"

module Jigsaw
  class Engine < ::Rails::Engine
    isolate_namespace Jigsaw

    initializer "jigsaw_engine.importmap", before: "importmap" do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << Engine.root.join("config/importmap.rb")
      end
    end

    initializer "jigsaw_engine.assets" do |app|
      ui_gem = Gem::Specification.find_by_name("rails-active-ui")
      app.config.assets.paths << File.join(ui_gem.gem_dir, "app/assets")
      app.config.assets.paths << root.join("app/assets/stylesheets")
      app.config.assets.paths << root.join("app/javascript")
    end
  end
end
