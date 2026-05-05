class CreateJigsawCustomPages < ActiveRecord::Migration[8.1]
  def change
    create_table :jigsaw_custom_pages do |t|
      t.string :path, null: false
      t.string :title, null: false

      t.timestamps
    end

    add_index :jigsaw_custom_pages, :path, unique: true
  end
end
