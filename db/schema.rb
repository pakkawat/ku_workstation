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

ActiveRecord::Schema.define(version: 20150605061956) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ku_users", force: :cascade do |t|
    t.string   "ku_id"
    t.string   "username"
    t.string   "password_digest"
    t.string   "firstname"
    t.string   "lastname"
    t.integer  "sex"
    t.string   "email"
    t.integer  "degree_level"
    t.integer  "faculty"
    t.integer  "major_field"
    t.integer  "status"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "campus"
    t.string   "remember_digest"
    t.boolean  "admin",           default: false
    t.text     "run_list"
  end

  add_index "ku_users", ["ku_id"], name: "index_ku_users_on_ku_id", unique: true, using: :btree

  create_table "program_files", force: :cascade do |t|
    t.integer  "program_id"
    t.string   "file_path"
    t.string   "file_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "program_files", ["program_id"], name: "index_program_files_on_program_id", using: :btree

  create_table "programs", force: :cascade do |t|
    t.string   "program_name"
    t.text     "note"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "programs_subjects", force: :cascade do |t|
    t.integer "program_id"
    t.integer "subject_id"
    t.boolean "program_enabled", default: true
  end

  add_index "programs_subjects", ["program_id"], name: "index_programs_subjects_on_program_id", using: :btree
  add_index "programs_subjects", ["subject_id"], name: "index_programs_subjects_on_subject_id", using: :btree

  create_table "subjects", force: :cascade do |t|
    t.string   "subject_id"
    t.string   "subject_name"
    t.integer  "term"
    t.string   "year"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "user_subjects", force: :cascade do |t|
    t.integer "ku_user_id"
    t.integer "subject_id"
    t.boolean "user_enabled", default: true
  end

  add_index "user_subjects", ["ku_user_id"], name: "index_user_subjects_on_ku_user_id", using: :btree
  add_index "user_subjects", ["subject_id"], name: "index_user_subjects_on_subject_id", using: :btree

  add_foreign_key "program_files", "programs"
end
