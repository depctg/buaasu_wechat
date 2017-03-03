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

ActiveRecord::Schema.define(version: 20161128150734) do

  create_table "canteen_degists", force: :cascade do |t|
    t.string   "degist"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.         "is_used",    default: "f"
    t.         "is_picked"
  end

  create_table "degists", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "subject"
    t.string   "degist_class"
    t.string   "content"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["user_id"], name: "index_degists_on_user_id"
  end

  create_table "sign_records", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "day"
    t.text     "days"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.datetime "last_sign_time"
    t.boolean  "lock"
    t.index ["last_sign_time"], name: "index_sign_records_on_last_sign_time"
    t.index ["user_id"], name: "index_sign_records_on_user_id"
  end

  create_table "treehole_messages", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "treehole_id"
    t.string   "content",     limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["treehole_id"], name: "index_treehole_messages_on_treehole_id"
    t.index ["user_id"], name: "index_treehole_messages_on_user_id"
  end

  create_table "treeholes", force: :cascade do |t|
    t.string   "name"
    t.integer  "count"
    t.boolean  "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "open_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "avatar"
    t.string   "nickname"
    t.index ["open_id"], name: "index_users_on_open_id"
  end

  create_table "wechat_sessions", force: :cascade do |t|
    t.string   "openid",     null: false
    t.string   "hash_store"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["openid"], name: "index_wechat_sessions_on_openid", unique: true
  end

end
