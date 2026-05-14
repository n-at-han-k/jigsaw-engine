module Jigsaw
  class LayoutTemplate < ApplicationRecord
    include GridConfigurable

    has_many :layouts, foreign_key: :layout_template_id, dependent: :nullify

    validates :name, presence: true, uniqueness: true

    # LayoutTemplate doesn't have child slots — it just defines the grid structure.
    # We provide a `slots` method stub so GridConfigurable's sync_slots doesn't blow up
    # if called, but it's not used on this model.
    def slots
      Slot.none
    end
  end
end
