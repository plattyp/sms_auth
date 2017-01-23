# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20170112031103) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authentication_tokens", force: :cascade do |t|
    t.string   "body"
    t.integer  "user_id"
    t.datetime "expired_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "authentication_tokens", ["body"], name: "index_authentication_tokens_on_body", unique: true, using: :btree
  add_index "authentication_tokens", ["user_id"], name: "index_authentication_tokens_on_user_id", using: :btree

  create_table "phone_verifications", force: :cascade do |t|
    t.string   "phone_number",                    null: false
    t.string   "verification_token",              null: false
    t.datetime "verified_at"
    t.datetime "expired_at"
    t.datetime "unlocked_at"
    t.string   "login_attempts",     default: [],              array: true
    t.integer  "user_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "phone_verifications", ["phone_number"], name: "index_phone_verifications_on_phone_number", unique: true, using: :btree
  add_index "phone_verifications", ["user_id"], name: "index_phone_verifications_on_user_id", unique: true, using: :btree
  add_index "phone_verifications", ["verification_token"], name: "index_phone_verifications_on_verification_token", using: :btree

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "authentication_tokens", "users"
  add_foreign_key "phone_verifications", "users"
end
