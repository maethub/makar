# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_31_125355) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "collections", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "filter_id"
  end

  create_table "collections_records", id: false, force: :cascade do |t|
    t.bigint "record_id", null: false
    t.bigint "collection_id", null: false
    t.index ["collection_id", "record_id"], name: "index_collections_records_on_collection_id_and_record_id"
    t.index ["record_id", "collection_id"], name: "index_collections_records_on_record_id_and_collection_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "filters", force: :cascade do |t|
    t.string "name"
    t.jsonb "query"
    t.index ["name"], name: "index_filters_on_name", unique: true
  end

  create_table "jobs", force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.string "parameters"
    t.text "output"
    t.string "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "record_values", force: :cascade do |t|
    t.string "name"
    t.string "value_type"
    t.jsonb "data"
    t.string "value_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "record_id"
    t.integer "index", default: 0
    t.index ["record_id", "name", "index"], name: "index_record_values_on_record_id_and_name_and_index", unique: true
    t.index ["record_id"], name: "index_record_values_on_record_id"
  end

  create_table "records", force: :cascade do |t|
    t.integer "schema_id"
    t.boolean "deactivated", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["schema_id"], name: "index_records_on_schema_id"
  end

  create_table "schemas", force: :cascade do |t|
    t.string "name"
    t.jsonb "schema"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
