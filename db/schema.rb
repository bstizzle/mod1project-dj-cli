# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 5) do

  create_table "playlist_tracks", force: :cascade do |t|
    t.integer "playlist_id"
    t.string "track_id"
  end

  create_table "playlist_users", force: :cascade do |t|
    t.integer "playlist_id"
    t.integer "user_id"
  end

  create_table "playlists", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "genre"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "password"
  end

end
