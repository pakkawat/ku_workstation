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

ActiveRecord::Schema.define(version: 20160309134126) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bash_scripts", force: :cascade do |t|
    t.text     "bash_script_content"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "chef_attributes", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "value"
    t.integer  "chef_resource_id"
  end

  add_index "chef_attributes", ["chef_resource_id"], name: "index_chef_attributes_on_chef_resource_id", using: :btree

  create_table "chef_properties", force: :cascade do |t|
    t.string   "value"
    t.string   "value_type"
    t.integer  "chef_resource_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "chef_properties", ["chef_resource_id"], name: "index_chef_properties_on_chef_resource_id", using: :btree

  create_table "chef_resources", force: :cascade do |t|
    t.string   "resource_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "priority"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",         default: 0, null: false
    t.integer  "attempts",         default: 0, null: false
    t.text     "handler",                      null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "progress_stage"
    t.integer  "progress_current", default: 0
    t.integer  "progress_max",     default: 0
    t.text     "description"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "instances", force: :cascade do |t|
    t.integer  "ku_user_id"
    t.string   "instance_name"
    t.string   "instance_id2"
    t.string   "instance_type"
    t.string   "public_dns"
    t.string   "public_ip"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "instances", ["ku_user_id"], name: "index_instances_on_ku_user_id", using: :btree

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

  create_table "logs", force: :cascade do |t|
    t.integer  "ku_user_id"
    t.string   "log_path"
    t.boolean  "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "logs", ["ku_user_id"], name: "index_logs_on_ku_user_id", using: :btree

  create_table "program_chefs", force: :cascade do |t|
    t.integer  "program_id"
    t.integer  "chef_resource_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "program_chefs", ["chef_resource_id"], name: "index_program_chefs_on_chef_resource_id", using: :btree
  add_index "program_chefs", ["program_id"], name: "index_program_chefs_on_program_id", using: :btree

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

  create_table "remove_resources", force: :cascade do |t|
    t.integer "program_id"
    t.string  "resource_type"
    t.string  "value"
    t.string  "value_type"
    t.integer "chef_resource_id"
  end

  add_index "remove_resources", ["program_id"], name: "index_remove_resources_on_program_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

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

  create_table "users_programs", force: :cascade do |t|
    t.integer "ku_user_id"
    t.integer "program_id"
    t.string  "subject_id"
  end

  add_index "users_programs", ["ku_user_id"], name: "index_users_programs_on_ku_user_id", using: :btree
  add_index "users_programs", ["program_id"], name: "index_users_programs_on_program_id", using: :btree

  add_foreign_key "program_files", "programs"
  add_foreign_key "remove_resources", "programs"
end
