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

ActiveRecord::Schema.define(version: 2021_12_15_220247) do

  create_table "magic_links_magic_tokens", force: :cascade do |t|
    t.string "token", null: false
    t.string "target_path", null: false
    t.json "action_scope", null: false
    t.datetime "expires_at"
    t.string "magic_token_authenticatable_type"
    t.integer "magic_token_authenticatable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["magic_token_authenticatable_type", "magic_token_authenticatable_id"], name: "index_magic_tokens_on_magic_token_authenticatable"
    t.index ["token"], name: "index_magic_links_magic_tokens_on_token", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
