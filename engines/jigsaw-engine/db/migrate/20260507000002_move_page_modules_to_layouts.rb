class MovePageModulesToLayouts < ActiveRecord::Migration[8.1]
  def change
    add_reference :jigsaw_page_modules, :layout,
                  foreign_key: { to_table: :jigsaw_layouts },
                  null: true

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE jigsaw_page_modules
          SET layout_id = jigsaw_layouts.id
          FROM jigsaw_layouts
          WHERE jigsaw_layouts.custom_page_id = jigsaw_page_modules.custom_page_id
        SQL
      end

      dir.down do
        execute <<~SQL
          UPDATE jigsaw_page_modules
          SET custom_page_id = jigsaw_layouts.custom_page_id
          FROM jigsaw_layouts
          WHERE jigsaw_layouts.id = jigsaw_page_modules.layout_id
        SQL
      end
    end

    remove_reference :jigsaw_page_modules, :custom_page,
                     foreign_key: { to_table: :jigsaw_custom_pages }
  end
end
