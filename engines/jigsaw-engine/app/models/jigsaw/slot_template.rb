module Jigsaw
  class SlotTemplate < ApplicationRecord
    acts_as_taggable_on :tags

    has_many :slots, foreign_key: :slot_template_id, dependent: :nullify

    validates :name, presence: true, uniqueness: true

    before_save :compile_sources

    private

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
