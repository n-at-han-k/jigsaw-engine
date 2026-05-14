# This migration comes from jigsaw (originally 20260509000001)
class CreateJigsawTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :jigsaw_templates do |t|
      t.string :name, null: false
      t.text :description
      t.string :thumbnail

      t.timestamps
    end

    add_index :jigsaw_templates, :name, unique: true
  end
end
