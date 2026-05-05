require "mini_racer"

module Jigsaw
  class JsxCompiler
    def self.compile(source)
      context = MiniRacer::Context.new
      context.eval(babel_source)
      context.eval(<<~JS)
        Babel.transform(#{source.to_json}, {
          presets: [['react', { runtime: 'automatic' }]]
        }).code
      JS
    ensure
      context&.dispose
    end

    def self.babel_source
      @babel_source ||= File.read(Engine.root.join("vendor/javascript/babel.min.js"))
    end
  end
end
