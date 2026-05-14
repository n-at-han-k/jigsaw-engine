class CreateJigsawTemplateLayouts < ActiveRecord::Migration[8.0]
  def change
    create_table :jigsaw_template_layouts do |t|
      t.references :template, null: false, foreign_key: { to_table: :jigsaw_templates }, index: { unique: true }
      t.jsonb :config, null: false, default: {}
      t.text :compiled_css
      t.string :compiled_digest

      t.timestamps
    end
  end
end
