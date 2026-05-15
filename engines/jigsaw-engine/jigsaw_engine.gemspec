require_relative "lib/jigsaw/version"

Gem::Specification.new do |spec|
  spec.name        = "jigsaw_engine"
  spec.version     = Jigsaw::VERSION
  spec.authors     = ["Nathan Kidd"]
  spec.summary     = "Jigsaw Engine"
  spec.homepage    = "https://github.com/general-intelligence-systems/jigsaw-engine"
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib,vendor}/**/*", "LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.1.3"
  spec.add_dependency "rails-active-ui", "~> 0.4"
  spec.add_dependency "mini_racer"
  spec.add_dependency "json_schemer", "~> 2.0"
  spec.add_dependency "acts_as_list"
  spec.add_dependency "acts-as-taggable-on", "~> 13.0"

  # Dummy host app + development tooling. These are not runtime deps of the
  # engine itself, but are required to boot the harness Rails app at the repo
  # root and the test/dummy app inside this engine.
  spec.add_development_dependency "pg", "~> 1.1"
  spec.add_development_dependency "propshaft"
  spec.add_development_dependency "falcon", "~> 0.55"
  spec.add_development_dependency "falcon-rails"
  spec.add_development_dependency "importmap-rails"
  spec.add_development_dependency "turbo-rails"
  spec.add_development_dependency "stimulus-rails"
  spec.add_development_dependency "solid_cache"
  spec.add_development_dependency "solid_queue"
  spec.add_development_dependency "image_processing", "~> 1.2"
  spec.add_development_dependency "web-console"
end
