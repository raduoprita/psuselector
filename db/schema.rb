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

ActiveRecord::Schema[7.1].define(version: 2024_07_24_175058) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "power_supplies", force: :cascade do |t|
    t.string "model"
    t.string "form_factor"
    t.integer "wattage"
    t.decimal "avg_efficiency"
    t.decimal "avg_efficiency_5vsb"
    t.decimal "vampire_power"
    t.decimal "avg_pf"
    t.decimal "avg_noise"
    t.string "efficiency_rating"
    t.string "noise_rating"
    t.date "release_date"
    t.string "manufacturer"
    t.string "atx_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "price"
  end

  create_table "psu_metadata", force: :cascade do |t|
    t.string "model"
    t.integer "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "favorite"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
