class RenameCustomPagesToPages < ActiveRecord::Migration[8.1]
  def up
    rename_table :jigsaw_custom_pages, :jigsaw_pages
    rename_column :jigsaw_layouts, :custom_page_id, :page_id

    if index_name_exists?(:jigsaw_pages, :index_jigsaw_custom_pages_on_path)
      rename_index :jigsaw_pages, :index_jigsaw_custom_pages_on_path, :index_jigsaw_pages_on_path
    end
  end

  def down
    if index_name_exists?(:jigsaw_pages, :index_jigsaw_pages_on_path)
      rename_index :jigsaw_pages, :index_jigsaw_pages_on_path, :index_jigsaw_custom_pages_on_path
    end
    rename_column :jigsaw_layouts, :page_id, :custom_page_id
    rename_table :jigsaw_pages, :jigsaw_custom_pages
  end
end
