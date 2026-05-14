class AddLinkedToTemplateToSlots < ActiveRecord::Migration[8.0]
  def change
    add_column :jigsaw_slots, :linked_to_template, :boolean, default: false, null: false
  end
end
