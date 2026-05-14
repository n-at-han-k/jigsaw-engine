class RenamePageModulesToSlots < ActiveRecord::Migration[8.1]
  def change
    rename_table :jigsaw_page_modules, :jigsaw_slots
    add_column :jigsaw_slots, :area_name, :string
    add_index :jigsaw_slots, [:layout_id, :area_name], unique: true, name: :index_jigsaw_slots_on_layout_id_and_area_name
  end
end
