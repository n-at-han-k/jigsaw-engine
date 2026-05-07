# This migration comes from jigsaw (originally 20260507000001)
class MoveLayoutFkToLayoutsTable < ActiveRecord::Migration[8.1]
  def change
    add_reference :jigsaw_layouts, :custom_page,
                  foreign_key: { to_table: :jigsaw_custom_pages },
                  null: true

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE jigsaw_layouts
          SET custom_page_id = jigsaw_custom_pages.id
          FROM jigsaw_custom_pages
          WHERE jigsaw_custom_pages.layout_id = jigsaw_layouts.id
        SQL
      end

      dir.down do
        execute <<~SQL
          UPDATE jigsaw_custom_pages
          SET layout_id = jigsaw_layouts.id
          FROM jigsaw_layouts
          WHERE jigsaw_layouts.custom_page_id = jigsaw_custom_pages.id
        SQL
      end
    end

    remove_reference :jigsaw_custom_pages, :layout,
                     foreign_key: { to_table: :jigsaw_layouts }
  end
end
