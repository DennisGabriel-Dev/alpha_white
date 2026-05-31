# frozen_string_literal: true

class CreateQuizAttempts < ActiveRecord::Migration[8.1]
  def change
    create_table :quiz_attempts, comment: "Quiz attempt by student (can have multiple after resubmission)." do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :quiz, null: false, foreign_key: true
      t.integer :attempt_number, null: false, default: 1
      t.datetime :started_at, null: false
      t.datetime :submitted_at
      t.integer :duration_seconds
      t.integer :time_limit_seconds, null: false, comment: "Snapshot do limite da aula no início"
      t.timestamps
    end

    add_index :quiz_attempts, [:tenant_id, :user_id, :quiz_id, :attempt_number],
              unique: true, name: "index_quiz_attempts_on_tenant_user_quiz_attempt"
    add_index :quiz_attempts, [:quiz_id, :user_id, :submitted_at],
              name: "index_quiz_attempts_on_quiz_user_submitted"
  end
end
