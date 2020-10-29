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

ActiveRecord::Schema.define(version: 2020_10_29_205700) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "campaigns", force: :cascade do |t|
    t.string "name"
    t.bigint "organization_id", null: false
    t.bigint "user_id", null: false
    t.jsonb "filters"
    t.integer "control_count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_campaigns_on_name"
    t.index ["organization_id"], name: "index_campaigns_on_organization_id"
    t.index ["user_id"], name: "index_campaigns_on_user_id"
  end

  create_table "controls", force: :cascade do |t|
    t.string "guid"
    t.string "control_pack"
    t.string "control_id"
    t.string "title"
    t.text "description"
    t.integer "impact"
    t.string "validation"
    t.string "remediation"
    t.jsonb "refs"
    t.integer "status", default: 0
    t.integer "resources_failed", default: 0
    t.integer "resources_total", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["control_id"], name: "index_controls_on_control_id"
    t.index ["control_pack"], name: "index_controls_on_control_pack"
    t.index ["guid"], name: "index_controls_on_guid"
    t.index ["title"], name: "index_controls_on_title"
  end

  create_table "identities", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "issues", force: :cascade do |t|
    t.integer "status"
    t.bigint "result_id", null: false
    t.bigint "resource_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["resource_id"], name: "index_issues_on_resource_id"
    t.index ["result_id"], name: "index_issues_on_result_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.integer "status"
    t.integer "issue_count"
    t.integer "kind"
    t.string "guid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["guid"], name: "index_jobs_on_guid"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_organizations_on_name"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "name"
    t.string "author"
    t.string "platform"
    t.jsonb "tags"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "resources", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_resources_on_name"
  end

  create_table "results", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.jsonb "data"
    t.bigint "control_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "observed_at", precision: 6
    t.index ["control_id"], name: "index_results_on_control_id"
    t.index ["job_id"], name: "index_results_on_job_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "sources", force: :cascade do |t|
    t.string "name"
    t.integer "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "tag_id", null: false
    t.bigint "control_id", null: false
    t.boolean "primary", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["control_id"], name: "index_taggings_on_control_id"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.bigint "organization_id", null: false
    t.string "username", default: "", null: false
    t.string "password_digest", default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "campaigns", "organizations"
  add_foreign_key "campaigns", "users"
  add_foreign_key "identities", "users"
  add_foreign_key "issues", "resources"
  add_foreign_key "issues", "results"
  add_foreign_key "results", "controls"
  add_foreign_key "results", "jobs"
  add_foreign_key "taggings", "controls"
  add_foreign_key "taggings", "tags"
  add_foreign_key "users", "organizations"
end
