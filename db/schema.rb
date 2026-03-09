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

ActiveRecord::Schema[8.1].define(version: 2026_03_09_162739) do
  create_table "lead_measures", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "current_value", precision: 10, scale: 2, default: "0.0"
    t.string "title", null: false
    t.string "unit", default: ""
    t.datetime "updated_at", null: false
    t.date "week_start_date", null: false
    t.decimal "weekly_target", precision: 10, scale: 2, null: false
    t.integer "wig_id", null: false
    t.index ["wig_id", "week_start_date"], name: "index_lead_measures_on_wig_id_and_week_start_date"
    t.index ["wig_id"], name: "index_lead_measures_on_wig_id"
  end

  create_table "members", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_members_on_name", unique: true
  end

  create_table "tasks", force: :cascade do |t|
    t.boolean "completed", default: false
    t.datetime "completed_at"
    t.decimal "contribution_value", precision: 10, scale: 2, default: "1.0"
    t.datetime "created_at", null: false
    t.integer "lead_measure_id", null: false
    t.integer "member_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.date "week_start_date", null: false
    t.index ["lead_measure_id", "week_start_date"], name: "index_tasks_on_lead_measure_id_and_week_start_date"
    t.index ["lead_measure_id"], name: "index_tasks_on_lead_measure_id"
    t.index ["member_id", "week_start_date"], name: "index_tasks_on_member_id_and_week_start_date"
    t.index ["member_id"], name: "index_tasks_on_member_id"
  end

  create_table "wigs", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.decimal "current_value", precision: 10, scale: 2, default: "0.0"
    t.date "deadline"
    t.text "description"
    t.decimal "target_value", precision: 10, scale: 2, null: false
    t.string "title", null: false
    t.string "unit", default: ""
    t.datetime "updated_at", null: false
  end

  add_foreign_key "lead_measures", "wigs"
  add_foreign_key "tasks", "lead_measures"
  add_foreign_key "tasks", "members"
end
