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

ActiveRecord::Schema.define(version: 20160430135942) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  add_index "events", ["user_id"], name: "index_events_on_user_id", using: :btree

  create_table "follows", force: :cascade do |t|
    t.integer  "user_1_id"
    t.integer  "user_2_id"
    t.boolean  "accepted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "follows", ["user_1_id"], name: "index_follows_on_user_1_id", using: :btree
  add_index "follows", ["user_2_id"], name: "index_follows_on_user_2_id", using: :btree

  create_table "images", force: :cascade do |t|
    t.integer  "imageable_id"
    t.string   "imageable_type"
    t.string   "imagefile_file_name"
    t.string   "imagefile_content_type"
    t.integer  "imagefile_file_size"
    t.datetime "imagefile_updated_at"
  end

  add_index "images", ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id", using: :btree

  create_table "joins", force: :cascade do |t|
    t.integer "event_id"
    t.integer "user_id"
    t.boolean "allowed"
  end

  add_index "joins", ["event_id"], name: "index_joins_on_event_id", using: :btree
  add_index "joins", ["user_id"], name: "index_joins_on_user_id", using: :btree

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
    t.string   "to_type"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "messages", ["from_id"], name: "index_messages_on_from_id", using: :btree
  add_index "messages", ["to_type", "to_id"], name: "index_messages_on_to_type_and_to_id", using: :btree

  create_table "references", force: :cascade do |t|
    t.integer  "from_id"
    t.integer  "to_id"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "references", ["from_id"], name: "index_references_on_from_id", using: :btree
  add_index "references", ["to_id"], name: "index_references_on_to_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.integer  "user_id"
    t.uuid     "auth_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "deviceId"
    t.integer  "deviceType"
    t.string   "pushToken"
  end

  add_index "sessions", ["auth_token"], name: "index_sessions_on_auth_token", using: :btree
  add_index "sessions", ["user_id"], name: "index_sessions_on_user_id", using: :btree

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
    t.boolean  "showPhone"
    t.boolean  "showFriends"
    t.boolean  "deleted"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "users", ["facebookID"], name: "index_users_on_facebookID", using: :btree
  add_index "users", ["googleID"], name: "index_users_on_googleID", using: :btree

end
