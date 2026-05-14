# This migration comes from jigsaw (originally 20260510000001)
class RefactorTemplatesToLayoutAndSlotTemplates < ActiveRecord::Migration[8.0]
  def change
    # --- Merge template_layouts into templates (becoming layout_templates) ---

    # Add grid config columns directly to jigsaw_templates
    add_column :jigsaw_templates, :config, :jsonb, null: false, default: {}
    add_column :jigsaw_templates, :compiled_css, :text
    add_column :jigsaw_templates, :compiled_digest, :string

    # Copy data from template_layouts into templates
    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE jigsaw_templates
          SET config = tl.config,
              compiled_css = tl.compiled_css,
              compiled_digest = tl.compiled_digest
          FROM jigsaw_template_layouts tl
          WHERE tl.template_id = jigsaw_templates.id
        SQL
      end
    end

    # Drop template_slots first (depends on template_layouts)
    drop_table :jigsaw_template_slots do |t|
      t.references :template_layout, null: false, foreign_key: { to_table: :jigsaw_template_layouts }
      t.string :area_name, null: false
      t.integer :position, null: false, default: 0
      t.jsonb :config, default: {}
      t.jsonb :shares, default: []
      t.text :data_source
      t.text :data_compiled_source
      t.string :data_compiled_digest
      t.text :render_source
      t.text :render_compiled_source
      t.string :render_compiled_digest
      t.string :render_language, null: false, default: "javascript"
      t.timestamps
    end

    # Drop template_layouts (merged into templates)
    drop_table :jigsaw_template_layouts do |t|
      t.references :template, null: false, foreign_key: { to_table: :jigsaw_templates }
      t.jsonb :config, null: false, default: {}
      t.text :compiled_css
      t.string :compiled_digest
      t.timestamps
    end

    # Rename jigsaw_templates -> jigsaw_layout_templates
    rename_table :jigsaw_templates, :jigsaw_layout_templates

    # --- Rename FK on layouts ---
    # Remove old FK and index, rename column, re-add
    remove_foreign_key :jigsaw_layouts, column: :template_id
    remove_index :jigsaw_layouts, :template_id if index_exists?(:jigsaw_layouts, :template_id)
    rename_column :jigsaw_layouts, :template_id, :layout_template_id
    add_foreign_key :jigsaw_layouts, :jigsaw_layout_templates, column: :layout_template_id
    add_index :jigsaw_layouts, :layout_template_id

    # --- Create slot_templates ---
    create_table :jigsaw_slot_templates do |t|
      t.string :name, null: false
      t.text :description
      t.string :thumbnail
      t.jsonb :config, default: {}
      t.jsonb :shares, default: []
      t.text :data_source
      t.text :data_compiled_source
      t.string :data_compiled_digest
      t.text :render_source
      t.text :render_compiled_source
      t.string :render_compiled_digest
      t.string :render_language, null: false, default: "javascript"

      t.timestamps
    end

    add_index :jigsaw_slot_templates, :name, unique: true

    # --- Add slot_template_id FK to slots ---
    add_reference :jigsaw_slots, :slot_template, foreign_key: { to_table: :jigsaw_slot_templates }, null: true

    # --- acts-as-taggable-on tables ---
    create_table :tags do |t|
      t.string :name
      t.timestamps
    end
    add_index :tags, :name, unique: true

    create_table :taggings do |t|
      t.references :tag, foreign_key: true
      t.references :taggable, polymorphic: true
      t.references :tagger, polymorphic: true
      t.string :context, limit: 128

      t.timestamps
    end

    add_index :taggings, [:taggable_type, :taggable_id, :context], name: "taggings_taggable_context_idx"
    add_index :taggings, [:tag_id, :taggable_id, :taggable_type, :context, :tagger_id, :tagger_type],
              unique: true, name: "taggings_idx"
  end
end
