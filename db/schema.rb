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

ActiveRecord::Schema[8.1].define(version: 2026_05_05_195813) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "jigsaw_custom_pages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "layout_id"
    t.string "path", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["layout_id"], name: "index_jigsaw_custom_pages_on_layout_id"
    t.index ["path"], name: "index_jigsaw_custom_pages_on_path", unique: true
  end

  create_table "jigsaw_data_functions", force: :cascade do |t|
    t.string "compiled_digest"
    t.text "compiled_source"
    t.datetime "created_at", null: false
    t.string "language", default: "javascript", null: false
    t.string "name", null: false
    t.text "source", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_jigsaw_data_functions_on_name", unique: true
  end

  create_table "jigsaw_layouts", force: :cascade do |t|
    t.text "compiled_css"
    t.string "compiled_digest"
    t.jsonb "config", default: {}, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_jigsaw_layouts_on_name", unique: true
  end

  create_table "jigsaw_page_modules", force: :cascade do |t|
    t.jsonb "config", default: {}
    t.datetime "created_at", null: false
    t.bigint "custom_page_id", null: false
    t.bigint "data_function_id", null: false
    t.integer "position", default: 0, null: false
    t.bigint "render_function_id", null: false
    t.jsonb "shares", default: []
    t.string "slot"
    t.datetime "updated_at", null: false
    t.index ["custom_page_id"], name: "index_jigsaw_page_modules_on_custom_page_id"
    t.index ["data_function_id"], name: "index_jigsaw_page_modules_on_data_function_id"
    t.index ["render_function_id"], name: "index_jigsaw_page_modules_on_render_function_id"
  end

  create_table "jigsaw_render_functions", force: :cascade do |t|
    t.string "compiled_digest"
    t.text "compiled_source"
    t.datetime "created_at", null: false
    t.string "language", default: "javascript", null: false
    t.string "name", null: false
    t.text "source", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_jigsaw_render_functions_on_name", unique: true
  end

  add_foreign_key "jigsaw_custom_pages", "jigsaw_layouts", column: "layout_id"
  add_foreign_key "jigsaw_page_modules", "jigsaw_custom_pages", column: "custom_page_id"
  add_foreign_key "jigsaw_page_modules", "jigsaw_data_functions", column: "data_function_id"
  add_foreign_key "jigsaw_page_modules", "jigsaw_render_functions", column: "render_function_id"
end
