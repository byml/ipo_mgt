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

ActiveRecord::Schema.define(version: 20160916125511) do

  create_table "account_infos", force: :cascade do |t|
    t.string   "code",           limit: 255
    t.integer  "broker_id",      limit: 4
    t.integer  "stakeholder_id", limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "account_infos", ["broker_id"], name: "index_account_infos_on_broker_id", using: :btree
  add_index "account_infos", ["stakeholder_id"], name: "index_account_infos_on_stakeholder_id", using: :btree

  create_table "account_ipo_matches", force: :cascade do |t|
    t.date    "apply_date"
    t.string  "apply_code",         limit: 255
    t.string  "match_code",         limit: 255
    t.string  "match_name",         limit: 255
    t.integer "first_match_number", limit: 8
    t.integer "match_count",        limit: 1
    t.integer "account_info_id",    limit: 4
  end

  add_index "account_ipo_matches", ["account_info_id"], name: "index_account_ipo_matches_on_account_info_id", using: :btree

  create_table "account_ipo_win_lots", force: :cascade do |t|
    t.string   "apply_code",      limit: 255
    t.integer  "win_lot_count",   limit: 4
    t.string   "win_lot_numbers", limit: 256
    t.integer  "account_info_id", limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "account_ipo_win_lots", ["account_info_id"], name: "index_account_ipo_win_lots_on_account_info_id", using: :btree

  create_table "brokers", force: :cascade do |t|
    t.string   "code",       limit: 255
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "ipo_issues", force: :cascade do |t|
    t.string   "stock_code",        limit: 255
    t.string   "stock_name",        limit: 255
    t.string   "apply_code",        limit: 255
    t.string   "match_code",        limit: 255
    t.date     "online_apply_date"
    t.date     "lot_declare_date"
    t.date     "pay_date"
    t.decimal  "issue_price",                    precision: 8, scale: 2
    t.date     "list_date"
    t.decimal  "online_lot_rate",                precision: 8, scale: 3
    t.string   "lot_result",        limit: 1024
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
  end

  create_table "ipo_win_lots", force: :cascade do |t|
    t.string   "apply_code",     limit: 20
    t.string   "ballot_numbers", limit: 1024
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "stakeholders", force: :cascade do |t|
    t.string   "code",       limit: 255
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_foreign_key "account_infos", "brokers"
  add_foreign_key "account_infos", "stakeholders"
  add_foreign_key "account_ipo_matches", "account_infos"
  add_foreign_key "account_ipo_win_lots", "account_infos"
end
