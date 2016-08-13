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

ActiveRecord::Schema.define(version: 20160813065710) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string   "year"
    t.string   "player_name"
    t.integer  "player_rank"
    t.string   "opponent_name"
    t.integer  "opponent_rank"
    t.string   "round"
    t.string   "score"
    t.string   "win_loss"
    t.string   "tournament_name"
    t.string   "tournament_category"
    t.string   "tournament_location"
    t.date     "tournament_start_date"
    t.date     "tournament_end_date"
    t.string   "tournament_surface"
    t.string   "tournament_surface_inout"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "activities", ["year", "player_name", "opponent_name", "round", "tournament_name"], name: "activities_uniq_index", unique: true, using: :btree

  create_table "activity_jobs", force: :cascade do |t|
    t.string   "player_name",             null: false
    t.string   "player_id",               null: false
    t.string   "year",                    null: false
    t.integer  "working",     default: 0
    t.integer  "finished",    default: 0
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "player_statuses", force: :cascade do |t|
    t.string   "year"
    t.string   "player_name"
    t.float    "stability"
    t.float    "toughness"
    t.float    "mentality"
    t.float    "explosive"
    t.float    "momentum"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "vs_top10_win"
    t.integer  "vs_top10_loss"
    t.integer  "vs_higher_win"
    t.integer  "vs_higher_loss"
    t.integer  "vs_lower_win"
    t.integer  "vs_lower_loss"
  end

  add_index "player_statuses", ["year", "player_name"], name: "player_statuses_uniq_index", unique: true, using: :btree

  create_table "players", force: :cascade do |t|
    t.string   "name"
    t.string   "url_name"
    t.string   "url_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "players", ["url_id"], name: "players_uniq_index", unique: true, using: :btree

  create_table "rankings", force: :cascade do |t|
    t.integer  "ranking"
    t.string   "name"
    t.integer  "points"
    t.date     "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "rankings", ["ranking", "name", "date"], name: "rankings_uniq_index", unique: true, using: :btree

end
