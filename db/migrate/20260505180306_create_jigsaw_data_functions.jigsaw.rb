# This migration comes from jigsaw (originally 20260505185637)
class CreateJigsawDataFunctions < ActiveRecord::Migration[8.1]
  def change
    create_table :jigsaw_data_functions do |t|
      t.string :name, null: false
      t.string :language, null: false, default: "javascript"
      t.text :source, null: false
      t.text :compiled_source
      t.string :compiled_digest

      t.timestamps
    end

    add_index :jigsaw_data_functions, :name, unique: true
  end
end
