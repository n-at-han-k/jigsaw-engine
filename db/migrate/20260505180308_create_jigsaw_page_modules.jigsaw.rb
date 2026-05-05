# This migration comes from jigsaw (originally 20260505185639)
class CreateJigsawPageModules < ActiveRecord::Migration[8.1]
  def change
    create_table :jigsaw_page_modules do |t|
      t.references :custom_page, null: false, foreign_key: { to_table: :jigsaw_custom_pages }
      t.references :data_function, null: false, foreign_key: { to_table: :jigsaw_data_functions }
      t.references :render_function, null: false, foreign_key: { to_table: :jigsaw_render_functions }
      t.integer :position, null: false, default: 0
      t.string :slot
      t.jsonb :config, default: {}
      t.jsonb :shares, default: []

      t.timestamps
    end
  end
end
