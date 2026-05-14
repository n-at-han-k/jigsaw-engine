require "acts_as_list"
require "acts-as-taggable-on"
require "json_schemer"
require "jigsaw"
require "jigsaw/version"
require "jigsaw/jsx_compiler"
require "jigsaw/grid_layout_generator"

module Jigsaw
  class Engine < ::Rails::Engine
    isolate_namespace Jigsaw

    initializer "jigsaw_engine.importmap", before: "importmap" do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << Engine.root.join("config/importmap.rb")
      end
    end

    initializer "jigsaw_engine.assets" do |app|
      if app.config.respond_to?(:assets) && app.config.assets.respond_to?(:paths)
        ui_gem = Gem::Specification.find_by_name("rails-active-ui")
        app.config.assets.paths << File.join(ui_gem.gem_dir, "app/assets")
        app.config.assets.paths << root.join("app/assets/stylesheets")
        app.config.assets.paths << root.join("app/javascript")
        app.config.assets.paths << Rails.root.join("app/assets/stylesheets")
      end
    end
  end
end
