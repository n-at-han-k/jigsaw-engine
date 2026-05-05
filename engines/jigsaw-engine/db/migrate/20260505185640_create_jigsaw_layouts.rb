class CreateJigsawLayouts < ActiveRecord::Migration[8.1]
  def change
    create_table :jigsaw_layouts do |t|
      t.string :name, null: false
      t.jsonb  :config, null: false, default: {}
      t.text   :compiled_css
      t.string :compiled_digest
      t.timestamps
    end

    add_index :jigsaw_layouts, :name, unique: true
    add_reference :jigsaw_custom_pages, :layout, foreign_key: { to_table: :jigsaw_layouts }, null: true
  end
end
