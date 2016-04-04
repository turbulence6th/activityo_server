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

ActiveRecord::Schema.define(version: 20160404133420) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: :cascade do |t|
    t.integer  "from_id"
    t.integer  "to_id"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "comments", ["from_id"], name: "index_comments_on_from_id", using: :btree
  add_index "comments", ["to_id"], name: "index_comments_on_to_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "eventType"
    t.string   "name"
    t.datetime "startDate"
    t.string   "address"
    t.integer  "capacity"
    t.text     "description"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "friends", force: :cascade do |t|
    t.integer  "user_1_id"
    t.integer  "user_2_id"
    t.boolean  "accepted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "friends", ["user_1_id"], name: "index_friends_on_user_1_id", using: :btree
  add_index "friends", ["user_2_id"], name: "index_friends_on_user_2_id", using: :btree

  create_table "likes", force: :cascade do |t|
    t.string "name"
    t.string "likeID"
  end

  add_index "likes", ["likeID"], name: "index_likes_on_likeID", using: :btree

  create_table "likes_users", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "like_id"
  end

  add_index "likes_users", ["like_id"], name: "index_likes_users_on_like_id", using: :btree
  add_index "likes_users", ["user_id"], name: "index_likes_users_on_user_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "from_id"
    t.integer  "to_id"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "messages", ["from_id"], name: "index_messages_on_from_id", using: :btree
  add_index "messages", ["to_id"], name: "index_messages_on_to_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.date     "birthday"
    t.integer  "gender"
    t.string   "education"
    t.string   "phone"
    t.integer  "role"
    t.text     "description"
    t.string   "facebookID"
    t.string   "googleID"
    t.string   "twitterID"
    t.uuid     "auth_token"
    t.uuid     "onesignal_token"
    t.boolean  "deleted"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "users", ["auth_token"], name: "index_users_on_auth_token", using: :btree
  add_index "users", ["facebookID"], name: "index_users_on_facebookID", using: :btree
  add_index "users", ["googleID"], name: "index_users_on_googleID", using: :btree
  add_index "users", ["onesignal_token"], name: "index_users_on_onesignal_token", using: :btree
  add_index "users", ["twitterID"], name: "index_users_on_twitterID", using: :btree

end
