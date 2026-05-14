module Jigsaw
  class Layout < ApplicationRecord
    include GridConfigurable

    belongs_to :page
    belongs_to :layout_template, optional: true
    has_many :slots, -> { order(:position) }, dependent: :destroy

    validates :name, presence: true, uniqueness: true

    def skip_config_validation?
      linked_to_template?
    end

    # --- Template Linking ---

    def effective_config
      if linked_to_template? && layout_template
        layout_template.config
      else
        config
      end
    end

    def effective_compiled_css
      if linked_to_template? && layout_template
        layout_template.compiled_css
      else
        compiled_css
      end
    end

    def unlink_from_template!
      return unless linked_to_template? && layout_template

      # Copy template's grid config locally
      self.config = layout_template.config.deep_dup
      self.linked_to_template = false
      self.layout_template = nil
      save!
    end

    def link_to_template!(tmpl)
      self.layout_template = tmpl
      self.linked_to_template = true
      save!
    end

    private

      # Override compile_css from concern to use effective_config
      def compile_css
        cfg = effective_config
        return if cfg.blank?

        generator = GridLayoutGenerator.new(cfg, id || SecureRandom.hex(4))
        self.compiled_css = generator.call
        self.compiled_digest = Digest::SHA256.hexdigest(compiled_css)
      end
  end
end
