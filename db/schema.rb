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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101020121103) do

  create_table "series", :force => true do |t|
    t.integer  "tvdb_id"
    t.string   "air_day"
    t.string   "air_time"
    t.string   "content_rating"
    t.date     "first_aired"
    t.string   "imdb_id"
    t.string   "language"
    t.string   "network"
    t.string   "description"
    t.decimal  "rating"
    t.integer  "rating_count"
    t.integer  "runtime"
    t.integer  "series_id"
    t.string   "name"
    t.string   "status"
    t.string   "banner"
    t.string   "fanart"
    t.string   "poster"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
