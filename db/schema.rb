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

ActiveRecord::Schema[8.1].define(version: 2025_11_26_160916) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "agencies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "deals", force: :cascade do |t|
    t.bigint "agency_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "recruter_id", null: false
    t.integer "stage"
    t.datetime "updated_at", null: false
    t.index ["agency_id"], name: "index_deals_on_agency_id"
    t.index ["recruter_id"], name: "index_deals_on_recruter_id"
  end

  create_table "recruters", force: :cascade do |t|
    t.bigint "agency_id", null: false
    t.datetime "created_at", null: false
    t.string "linkedin_chat_url"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["agency_id"], name: "index_recruters_on_agency_id"
  end

  add_foreign_key "deals", "agencies"
  add_foreign_key "deals", "recruters"
  add_foreign_key "recruters", "agencies"
end
