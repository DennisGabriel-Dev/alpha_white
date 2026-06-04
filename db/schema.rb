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

ActiveRecord::Schema[8.1].define(version: 2026_05_30_130000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "achievements", comment: "Global achievement catalog (badges).", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.integer "kind", default: 0, null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "threshold", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_achievements_on_slug", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

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

  create_table "enem_exams", comment: "Canonical ENEM exam edition (global, no tenant).", force: :cascade do |t|
    t.string "booklet_color", null: false
    t.datetime "created_at", null: false
    t.string "day", null: false, comment: "D1 or D2"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "updated_at", null: false
    t.integer "year", null: false
    t.index ["year", "day", "booklet_color"], name: "index_enem_exams_on_year_day_booklet", unique: true
  end

  create_table "enem_import_jobs", comment: "Tenant-scoped import jobs for ENEM PDF pairs.", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "enem_exam_id"
    t.text "error_message"
    t.integer "status", default: 0, null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["enem_exam_id"], name: "index_enem_import_jobs_on_enem_exam_id"
    t.index ["tenant_id", "id"], name: "index_enem_import_jobs_on_tenant_id_and_id"
    t.index ["tenant_id", "status", "created_at"], name: "index_enem_import_jobs_on_tenant_id_and_status_and_created_at"
    t.index ["tenant_id"], name: "index_enem_import_jobs_on_tenant_id"
    t.index ["user_id"], name: "index_enem_import_jobs_on_user_id"
  end

  create_table "enem_questions", comment: "Official ENEM question (global library).", force: :cascade do |t|
    t.jsonb "alternatives", default: [], null: false
    t.string "area", null: false, comment: "LC, CH, CN, MT"
    t.string "correct_letter", null: false
    t.datetime "created_at", null: false
    t.bigint "enem_exam_id", null: false
    t.integer "number_in_exam", null: false
    t.string "skill"
    t.text "statement", null: false
    t.datetime "updated_at", null: false
    t.index ["area"], name: "index_enem_questions_on_area"
    t.index ["enem_exam_id", "number_in_exam"], name: "index_enem_questions_on_exam_and_number", unique: true
    t.index ["enem_exam_id"], name: "index_enem_questions_on_enem_exam_id"
  end

  create_table "feedbacks", comment: "Student feedback on a lesson (rating + description).", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "lesson_id", null: false
    t.integer "rating", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["lesson_id", "user_id"], name: "index_feedbacks_on_lesson_id_and_user_id", unique: true
    t.index ["lesson_id"], name: "index_feedbacks_on_lesson_id"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "lesson_completions", comment: "Lesson completion record by the student (quiz done, video watched).", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "lesson_id", null: false
    t.boolean "quiz_completed", default: false, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.boolean "video_watched", default: false, null: false
    t.index ["lesson_id", "user_id"], name: "index_lesson_completions_on_lesson_id_and_user_id", unique: true
    t.index ["lesson_id"], name: "index_lesson_completions_on_lesson_id"
    t.index ["user_id"], name: "index_lesson_completions_on_user_id"
  end

  create_table "lessons", comment: "Lessons inside a session. Each lesson can have a video, description and quizzes.", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.integer "quiz_time_limit_seconds", default: 600, null: false, comment: "Limit of time for the quiz of this lesson (seconds). Default: 10 min."
    t.bigint "session_id", null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.string "video_url"
    t.index ["session_id", "position"], name: "index_lessons_on_session_id_and_position"
    t.index ["session_id"], name: "index_lessons_on_session_id"
    t.index ["tenant_id", "id"], name: "index_lessons_on_tenant_id_and_id"
    t.index ["tenant_id"], name: "index_lessons_on_tenant_id"
  end

  create_table "question_options", comment: "Dynamic alternatives for a question. Only one can be correct.", force: :cascade do |t|
    t.boolean "correct", default: false, null: false
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.bigint "question_id", null: false
    t.text "text", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id", "position"], name: "index_question_options_on_question_id_and_position"
    t.index ["question_id"], name: "index_question_options_on_question_id"
  end

  create_table "questions", comment: "Questions of a quiz. Each question is the enunciation of the quiz.", force: :cascade do |t|
    t.string "correct_answer"
    t.datetime "created_at", null: false
    t.bigint "enem_question_id"
    t.text "enunciation", null: false
    t.integer "position", default: 0, null: false
    t.bigint "quiz_id", null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["enem_question_id"], name: "index_questions_on_enem_question_id"
    t.index ["quiz_id", "position"], name: "index_questions_on_quiz_id_and_position"
    t.index ["quiz_id"], name: "index_questions_on_quiz_id"
    t.index ["tenant_id", "enem_question_id"], name: "index_questions_on_tenant_id_and_enem_question_id"
    t.index ["tenant_id", "id"], name: "index_questions_on_tenant_id_and_id"
    t.index ["tenant_id"], name: "index_questions_on_tenant_id"
  end

  create_table "quiz_attempts", comment: "Quiz attempt by student (can have multiple after resubmission).", force: :cascade do |t|
    t.integer "attempt_number", default: 1, null: false
    t.datetime "created_at", null: false
    t.integer "duration_seconds"
    t.bigint "quiz_id", null: false
    t.datetime "started_at", null: false
    t.datetime "submitted_at"
    t.bigint "tenant_id", null: false
    t.integer "time_limit_seconds", null: false, comment: "Snapshot do limite da aula no início"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["quiz_id", "user_id", "submitted_at"], name: "index_quiz_attempts_on_quiz_user_submitted"
    t.index ["quiz_id"], name: "index_quiz_attempts_on_quiz_id"
    t.index ["tenant_id", "user_id", "quiz_id", "attempt_number"], name: "index_quiz_attempts_on_tenant_user_quiz_attempt", unique: true
    t.index ["tenant_id"], name: "index_quiz_attempts_on_tenant_id"
    t.index ["user_id"], name: "index_quiz_attempts_on_user_id"
  end

  create_table "quizzes", comment: "Quizzes associated with a lesson.", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "lesson_id", null: false
    t.bigint "tenant_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id"], name: "index_quizzes_on_lesson_id"
    t.index ["tenant_id", "id"], name: "index_quizzes_on_tenant_id_and_id"
    t.index ["tenant_id"], name: "index_quizzes_on_tenant_id"
  end

  create_table "sessions", comment: "Sessions of a course. Each session belongs to a course and tenant.", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "position"], name: "index_sessions_on_course_id_and_position"
    t.index ["course_id"], name: "index_sessions_on_course_id"
    t.index ["tenant_id", "id"], name: "index_sessions_on_tenant_id_and_id"
    t.index ["tenant_id"], name: "index_sessions_on_tenant_id"
  end

  create_table "student_answers", comment: "Individual student answer to a question.", force: :cascade do |t|
    t.text "answer"
    t.datetime "created_at", null: false
    t.bigint "question_id", null: false
    t.bigint "question_option_id"
    t.bigint "quiz_attempt_id", null: false
    t.string "selected_option"
    t.integer "time_spent_seconds"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["question_id"], name: "index_student_answers_on_question_id"
    t.index ["question_option_id"], name: "index_student_answers_on_question_option_id"
    t.index ["quiz_attempt_id", "question_id"], name: "index_student_answers_on_attempt_and_question", unique: true
    t.index ["quiz_attempt_id"], name: "index_student_answers_on_quiz_attempt_id"
    t.index ["user_id"], name: "index_student_answers_on_user_id"
  end

  create_table "study_streaks", comment: "Daily study streak per student and tenant.", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "current_streak", default: 0, null: false
    t.date "last_activity_on"
    t.integer "longest_streak", default: 0, null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["tenant_id", "user_id"], name: "index_study_streaks_on_tenant_id_and_user_id", unique: true
    t.index ["tenant_id"], name: "index_study_streaks_on_tenant_id"
    t.index ["user_id"], name: "index_study_streaks_on_user_id"
  end

  create_table "tenants", comment: "Table tenants (schools). Each tenant represents a whitelabel school.", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.jsonb "feature_flags", default: {}, null: false
    t.string "logo_url"
    t.string "meta_description"
    t.string "name", null: false
    t.string "primary_color", default: "#3C0094"
    t.string "subdomain", null: false, comment: "Unique subdomain for the tenant (ex: 'objetivo' for objetivo.seudominio.com)"
    t.string "tagline"
    t.string "theme", default: "default", null: false
    t.datetime "updated_at", null: false
    t.index ["subdomain"], name: "index_tenants_on_subdomain", unique: true
    t.check_constraint "subdomain::text = lower(subdomain::text)", name: "subdomain_lowercase"
  end

  create_table "user_achievements", comment: "Badge awarded to a user within a tenant.", force: :cascade do |t|
    t.bigint "achievement_id", null: false
    t.datetime "awarded_at", null: false
    t.datetime "created_at", null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["achievement_id"], name: "index_user_achievements_on_achievement_id"
    t.index ["tenant_id", "user_id", "achievement_id"], name: "index_user_achievements_on_tenant_user_achievement", unique: true
    t.index ["tenant_id"], name: "index_user_achievements_on_tenant_id"
    t.index ["user_id"], name: "index_user_achievements_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", null: false
    t.bigint "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "courses", "tenants"
  add_foreign_key "enem_import_jobs", "enem_exams"
  add_foreign_key "enem_import_jobs", "tenants"
  add_foreign_key "enem_import_jobs", "users"
  add_foreign_key "enem_questions", "enem_exams"
  add_foreign_key "feedbacks", "lessons"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "lesson_completions", "lessons"
  add_foreign_key "lesson_completions", "users"
  add_foreign_key "lessons", "sessions"
  add_foreign_key "lessons", "tenants"
  add_foreign_key "question_options", "questions"
  add_foreign_key "questions", "enem_questions"
  add_foreign_key "questions", "quizzes"
  add_foreign_key "questions", "tenants"
  add_foreign_key "quiz_attempts", "quizzes"
  add_foreign_key "quiz_attempts", "tenants"
  add_foreign_key "quiz_attempts", "users"
  add_foreign_key "quizzes", "lessons"
  add_foreign_key "quizzes", "tenants"
  add_foreign_key "sessions", "courses"
  add_foreign_key "sessions", "tenants"
  add_foreign_key "student_answers", "question_options"
  add_foreign_key "student_answers", "questions"
  add_foreign_key "student_answers", "quiz_attempts"
  add_foreign_key "student_answers", "users"
  add_foreign_key "study_streaks", "tenants"
  add_foreign_key "study_streaks", "users"
  add_foreign_key "user_achievements", "achievements"
  add_foreign_key "user_achievements", "tenants"
  add_foreign_key "user_achievements", "users"
  add_foreign_key "users", "tenants"
end
