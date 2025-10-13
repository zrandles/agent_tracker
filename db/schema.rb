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

ActiveRecord::Schema[8.0].define(version: 2025_10_13_170757) do
  create_table "agent_changes", force: :cascade do |t|
    t.integer "agent_id", null: false
    t.string "change_type", null: false
    t.text "change_description", null: false
    t.text "before_value"
    t.text "after_value"
    t.string "triggered_by", null: false
    t.integer "agent_invocation_id"
    t.integer "agent_issue_id"
    t.integer "agent_improvement_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id", "created_at"], name: "index_agent_changes_on_agent_id_and_created_at"
    t.index ["agent_id"], name: "index_agent_changes_on_agent_id"
    t.index ["agent_improvement_id"], name: "index_agent_changes_on_agent_improvement_id"
    t.index ["agent_invocation_id"], name: "index_agent_changes_on_agent_invocation_id"
    t.index ["agent_issue_id"], name: "index_agent_changes_on_agent_issue_id"
    t.index ["change_type"], name: "index_agent_changes_on_change_type"
    t.index ["triggered_by"], name: "index_agent_changes_on_triggered_by"
  end

  create_table "agent_improvements", force: :cascade do |t|
    t.integer "agent_id", null: false
    t.text "improvement_description", null: false
    t.integer "priority", null: false
    t.string "status", default: "proposed", null: false
    t.datetime "implemented_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id", "status"], name: "index_agent_improvements_on_agent_id_and_status"
    t.index ["agent_id"], name: "index_agent_improvements_on_agent_id"
    t.index ["priority"], name: "index_agent_improvements_on_priority"
    t.index ["status"], name: "index_agent_improvements_on_status"
  end

  create_table "agent_invocations", force: :cascade do |t|
    t.integer "agent_id", null: false
    t.text "task_description", null: false
    t.string "invocation_mode", null: false
    t.text "context_notes"
    t.datetime "started_at", null: false
    t.datetime "completed_at"
    t.integer "duration_minutes"
    t.boolean "success"
    t.integer "satisfaction_rating"
    t.text "outcome_notes"
    t.integer "tokens_input"
    t.integer "tokens_output"
    t.integer "tokens_total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id", "started_at"], name: "index_agent_invocations_on_agent_id_and_started_at"
    t.index ["agent_id"], name: "index_agent_invocations_on_agent_id"
    t.index ["invocation_mode"], name: "index_agent_invocations_on_invocation_mode"
    t.index ["started_at"], name: "index_agent_invocations_on_started_at"
    t.index ["success"], name: "index_agent_invocations_on_success"
  end

  create_table "agent_issues", force: :cascade do |t|
    t.integer "agent_id", null: false
    t.integer "agent_invocation_id"
    t.text "issue_description", null: false
    t.integer "severity", null: false
    t.string "status", default: "open", null: false
    t.text "resolution_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id", "status"], name: "index_agent_issues_on_agent_id_and_status"
    t.index ["agent_id"], name: "index_agent_issues_on_agent_id"
    t.index ["agent_invocation_id"], name: "index_agent_issues_on_agent_invocation_id"
    t.index ["severity"], name: "index_agent_issues_on_severity"
    t.index ["status"], name: "index_agent_issues_on_status"
  end

  create_table "agents", force: :cascade do |t|
    t.integer "agent_number", null: false
    t.string "name", null: false
    t.string "category", null: false
    t.integer "tier", null: false
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_number"], name: "index_agents_on_agent_number", unique: true
    t.index ["category"], name: "index_agents_on_category"
    t.index ["status"], name: "index_agents_on_status"
    t.index ["tier"], name: "index_agents_on_tier"
  end

  add_foreign_key "agent_changes", "agent_improvements"
  add_foreign_key "agent_changes", "agent_invocations"
  add_foreign_key "agent_changes", "agent_issues"
  add_foreign_key "agent_changes", "agents"
  add_foreign_key "agent_improvements", "agents"
  add_foreign_key "agent_invocations", "agents"
  add_foreign_key "agent_issues", "agent_invocations"
  add_foreign_key "agent_issues", "agents"
end
