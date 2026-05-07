class InlineFunctionsOnPageModules < ActiveRecord::Migration[8.1]
  def change
    add_column :jigsaw_page_modules, :data_source, :text
    add_column :jigsaw_page_modules, :data_compiled_source, :text
    add_column :jigsaw_page_modules, :data_compiled_digest, :string
    add_column :jigsaw_page_modules, :render_source, :text
    add_column :jigsaw_page_modules, :render_compiled_source, :text
    add_column :jigsaw_page_modules, :render_compiled_digest, :string
    add_column :jigsaw_page_modules, :render_language, :string, null: false, default: "javascript"

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE jigsaw_page_modules pm
          SET data_source = df.source,
              data_compiled_source = df.compiled_source,
              data_compiled_digest = df.compiled_digest
          FROM jigsaw_data_functions df
          WHERE pm.data_function_id = df.id
        SQL

        execute <<~SQL
          UPDATE jigsaw_page_modules pm
          SET render_source = rf.source,
              render_compiled_source = rf.compiled_source,
              render_compiled_digest = rf.compiled_digest,
              render_language = rf.language
          FROM jigsaw_render_functions rf
          WHERE pm.render_function_id = rf.id
        SQL
      end
    end

    remove_reference :jigsaw_page_modules, :data_function, foreign_key: { to_table: :jigsaw_data_functions }
    remove_reference :jigsaw_page_modules, :render_function, foreign_key: { to_table: :jigsaw_render_functions }

    drop_table :jigsaw_data_functions do |t|
      t.string :name, null: false
      t.string :language, null: false, default: "javascript"
      t.text :source, null: false
      t.text :compiled_source
      t.string :compiled_digest
      t.timestamps
    end

    drop_table :jigsaw_render_functions do |t|
      t.string :name, null: false
      t.string :language, null: false, default: "javascript"
      t.text :source, null: false
      t.text :compiled_source
      t.string :compiled_digest
      t.timestamps
    end
  end
end
