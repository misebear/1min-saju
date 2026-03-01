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

ActiveRecord::Schema[8.1].define(version: 2026_03_01_000003) do
  create_table "celebrity_images", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "fetched_at"
    t.string "image_url"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_celebrity_images_on_name", unique: true
  end

  create_table "dream_interpretations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "dream_text", null: false
    t.string "keywords_key", null: false
    t.text "result_json", null: false
    t.datetime "updated_at", null: false
    t.integer "use_count", default: 1
    t.index ["keywords_key"], name: "index_dream_interpretations_on_keywords_key"
  end

  create_table "saju_records", force: :cascade do |t|
    t.date "birth_date", null: false
    t.integer "birth_hour", null: false
    t.string "city", default: "서울"
    t.datetime "created_at", null: false
    t.string "gender", default: "남"
    t.string "memo", default: ""
    t.string "name", default: ""
    t.text "result_json"
    t.datetime "updated_at", null: false
    t.index ["birth_date"], name: "index_saju_records_on_birth_date"
    t.index ["created_at"], name: "index_saju_records_on_created_at"
  end
end
