module Jigsaw
  class Slot < ApplicationRecord
    belongs_to :layout
    belongs_to :slot_template, optional: true

    def self.slot_list_scope
      :layout
    end

    def self.slot_uniqueness_scope
      :layout_id
    end

    include SlotCompilable

    # --- Template Linking ---

    def effective_data_source
      if linked_to_template? && slot_template
        slot_template.data_source
      else
        data_source
      end
    end

    def effective_data_compiled_source
      if linked_to_template? && slot_template
        slot_template.data_compiled_source
      else
        data_compiled_source
      end
    end

    def effective_data_compiled_digest
      if linked_to_template? && slot_template
        slot_template.data_compiled_digest
      else
        data_compiled_digest
      end
    end

    def effective_render_source
      if linked_to_template? && slot_template
        slot_template.render_source
      else
        render_source
      end
    end

    def effective_render_compiled_source
      if linked_to_template? && slot_template
        slot_template.render_compiled_source
      else
        render_compiled_source
      end
    end

    def effective_render_compiled_digest
      if linked_to_template? && slot_template
        slot_template.render_compiled_digest
      else
        render_compiled_digest
      end
    end

    def effective_config
      if linked_to_template? && slot_template
        slot_template.config
      else
        config
      end
    end

    def effective_shares
      if linked_to_template? && slot_template
        slot_template.shares
      else
        shares
      end
    end

    def effective_render_language
      if linked_to_template? && slot_template
        slot_template.render_language
      else
        render_language
      end
    end

    def unlink_from_template!
      return unless linked_to_template? && slot_template

      self.data_source = slot_template.data_source
      self.render_source = slot_template.render_source
      self.render_language = slot_template.render_language
      self.config = slot_template.config.deep_dup
      self.shares = slot_template.shares.deep_dup
      self.linked_to_template = false
      self.slot_template = nil
      save!
    end

    def link_to_template!(tmpl)
      self.slot_template = tmpl
      self.linked_to_template = true
      save!
    end
  end
end
