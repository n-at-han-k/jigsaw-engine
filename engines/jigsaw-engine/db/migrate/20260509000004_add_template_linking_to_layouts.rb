class AddTemplateLinkingToLayouts < ActiveRecord::Migration[8.0]
  def change
    add_column :jigsaw_layouts, :linked_to_template, :boolean, default: false, null: false
    add_reference :jigsaw_layouts, :template, foreign_key: { to_table: :jigsaw_templates }, null: true
  end
end
