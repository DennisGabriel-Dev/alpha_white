# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_02_03_000001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "courses", comment: "Table courses. Each course belongs to a specific tenant.", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.bigint "tenant_id", null: false, comment: "Reference to the tenant (school) owner of this course"
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "id"], name: "index_courses_on_tenant_id_and_id"
    t.index ["tenant_id", "name"], name: "index_courses_on_tenant_id_and_name"
    t.index ["tenant_id"], name: "index_courses_on_tenant_id"
  end

  create_table "tenants", comment: "Table tenants (schools). Each tenant represents a whitelabel school.", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "logo_url"
    t.string "name", null: false
    t.string "primary_color", default: "#3C0094"
    t.string "subdomain", null: false, comment: "Unique subdomain for the tenant (ex: 'objetivo' for objetivo.seudominio.com)"
    t.datetime "updated_at", null: false
    t.index ["subdomain"], name: "index_tenants_on_subdomain", unique: true
    t.check_constraint "subdomain::text = lower(subdomain::text)", name: "subdomain_lowercase"
  end

  add_foreign_key "courses", "tenants"
end
