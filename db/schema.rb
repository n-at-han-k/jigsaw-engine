# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_05_14_212346) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "jigsaw_layout_templates", force: :cascade do |t|
    t.text "compiled_css"
    t.string "compiled_digest"
    t.jsonb "config", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "thumbnail"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_jigsaw_layout_templates_on_name", unique: true
  end

  create_table "jigsaw_layouts", force: :cascade do |t|
    t.text "compiled_css"
    t.string "compiled_digest"
    t.jsonb "config", default: {}, null: false
    t.datetime "created_at", null: false
    t.bigint "layout_template_id"
    t.boolean "linked_to_template", default: false, null: false
    t.string "name", null: false
    t.bigint "page_id"
    t.datetime "updated_at", null: false
    t.index ["layout_template_id"], name: "index_jigsaw_layouts_on_layout_template_id"
    t.index ["name"], name: "index_jigsaw_layouts_on_name", unique: true
    t.index ["page_id"], name: "index_jigsaw_layouts_on_page_id"
  end

  create_table "jigsaw_pages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "path", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["path"], name: "index_jigsaw_pages_on_path", unique: true
  end

  create_table "jigsaw_slot_templates", force: :cascade do |t|
    t.jsonb "config", default: {}
    t.datetime "created_at", null: false
    t.string "data_compiled_digest"
    t.text "data_compiled_source"
    t.text "data_source"
    t.text "description"
    t.string "name", null: false
    t.string "render_compiled_digest"
    t.text "render_compiled_source"
    t.string "render_language", default: "javascript", null: false
    t.text "render_source"
    t.jsonb "shares", default: []
    t.string "thumbnail"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_jigsaw_slot_templates_on_name", unique: true
  end

  create_table "jigsaw_slots", force: :cascade do |t|
    t.string "area_name"
    t.jsonb "config", default: {}
    t.datetime "created_at", null: false
    t.string "data_compiled_digest"
    t.text "data_compiled_source"
    t.text "data_source"
    t.bigint "layout_id"
    t.boolean "linked_to_template", default: false, null: false
    t.integer "position", default: 0, null: false
    t.string "render_compiled_digest"
    t.text "render_compiled_source"
    t.string "render_language", default: "javascript", null: false
    t.text "render_source"
    t.jsonb "shares", default: []
    t.bigint "slot_template_id"
    t.datetime "updated_at", null: false
    t.index ["layout_id", "area_name"], name: "index_jigsaw_slots_on_layout_id_and_area_name", unique: true
    t.index ["layout_id"], name: "index_jigsaw_slots_on_layout_id"
    t.index ["slot_template_id"], name: "index_jigsaw_slots_on_slot_template_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.string "context", limit: 128
    t.datetime "created_at", null: false
    t.bigint "tag_id"
    t.bigint "taggable_id"
    t.string "taggable_type"
    t.bigint "tagger_id"
    t.string "tagger_type"
    t.datetime "updated_at", null: false
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  add_foreign_key "jigsaw_layouts", "jigsaw_layout_templates", column: "layout_template_id"
  add_foreign_key "jigsaw_layouts", "jigsaw_pages", column: "page_id"
  add_foreign_key "jigsaw_slots", "jigsaw_layouts", column: "layout_id"
  add_foreign_key "jigsaw_slots", "jigsaw_slot_templates", column: "slot_template_id"
  add_foreign_key "taggings", "tags"
end
