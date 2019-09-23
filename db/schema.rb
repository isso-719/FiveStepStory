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

ActiveRecord::Schema.define(version: 20190818045230) do

  create_table "contents", force: :cascade do |t|
    t.integer "user_id"
    t.string "c_when"
    t.string "c_where"
    t.string "c_who"
    t.string "c_what"
    t.string "c_how"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_contents_on_user_id"
  end

  create_table "counts", force: :cascade do |t|
    t.integer "count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "game_users", force: :cascade do |t|
    t.integer "user_id"
    t.integer "game_id"
    t.index ["game_id"], name: "index_game_users_on_game_id"
    t.index ["user_id"], name: "index_game_users_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "turn"
    t.string "status"
    t.integer "user_id"
    t.integer "pass_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stones", force: :cascade do |t|
    t.string "color"
    t.integer "x"
    t.integer "y"
    t.integer "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "password_digest"
  end

end
