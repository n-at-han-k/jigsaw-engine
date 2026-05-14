# This migration comes from jigsaw (originally 20260509000003)
class CreateJigsawTemplateSlots < ActiveRecord::Migration[8.0]
  def change
    create_table :jigsaw_template_slots do |t|
      t.references :template_layout, null: false, foreign_key: { to_table: :jigsaw_template_layouts }
      t.string :area_name, null: false
      t.integer :position, null: false, default: 0
      t.jsonb :config, default: {}
      t.jsonb :shares, default: []
      t.text :data_source
      t.text :data_compiled_source
      t.string :data_compiled_digest
      t.text :render_source
      t.text :render_compiled_source
      t.string :render_compiled_digest
      t.string :render_language, null: false, default: "javascript"

      t.timestamps
    end

    add_index :jigsaw_template_slots, [:template_layout_id, :area_name], unique: true, name: "idx_template_slots_on_layout_and_area"
  end
end
