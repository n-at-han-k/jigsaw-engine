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
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.1.3"
  spec.add_dependency "rails-active-ui", "~> 0.3"
  spec.add_dependency "mini_racer"
  spec.add_dependency "json_schemer", "~> 2.0"
  spec.add_dependency "acts_as_list"
end
