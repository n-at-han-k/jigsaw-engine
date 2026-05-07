module Jigsaw
  class PageModule < ApplicationRecord
    belongs_to :layout

    acts_as_list scope: :layout

    after_initialize :set_default_sources
    before_save :compile_sources

    private

    def set_default_sources
      if data_source.blank?
        self.data_source = <<~JS
          export default function(shared, config) {
            return { title: config.title || "Module" }
          }
        JS
      end

      if render_source.blank?
        self.render_source = <<~JS
          export default function(data) {
            this.element.innerHTML = `
              <div style="padding: 1em; border: 1px dashed #ccc; border-radius: 4px; text-align: center; color: #666;">
                <strong>${data.title}</strong>
                <p style="margin: 0.5em 0 0; font-size: 0.85em;">Click edit to configure</p>
              </div>
            `
          }
        JS
      end
    end

    def compile_sources
      if data_source_changed? && data_source.present?
        self.data_compiled_source = data_source
        self.data_compiled_digest = Digest::SHA256.hexdigest(data_source)
      end

      if render_source_changed? && render_source.present?
        if render_language == "jsx"
          self.render_compiled_source = JsxCompiler.compile(render_source)
        else
          self.render_compiled_source = render_source
        end
        self.render_compiled_digest = Digest::SHA256.hexdigest(render_source)
      end
    end
  end
end
