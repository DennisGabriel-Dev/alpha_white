# frozen_string_literal: true

class AddQuizAttemptToStudentAnswers < ActiveRecord::Migration[8.1]
  def up
    add_reference :student_answers, :quiz_attempt, foreign_key: true, null: true
    add_column :student_answers, :time_spent_seconds, :integer

    remove_index :student_answers, name: "index_student_answers_on_question_id_and_user_id"

    backfill_quiz_attempts

    change_column_null :student_answers, :quiz_attempt_id, false
    add_index :student_answers, [:quiz_attempt_id, :question_id],
              unique: true, name: "index_student_answers_on_attempt_and_question"
  end

  def down
    remove_index :student_answers, name: "index_student_answers_on_attempt_and_question"
    remove_reference :student_answers, :quiz_attempt, foreign_key: true
    remove_column :student_answers, :time_spent_seconds
    add_index :student_answers, [:question_id, :user_id],
              unique: true, name: "index_student_answers_on_question_id_and_user_id"
  end

  private

  def backfill_quiz_attempts
    return unless table_exists?(:quiz_attempts)

    say_with_time "Backfill quiz_attempts for existing student_answers" do
      pairs = execute(<<~SQL.squish).to_a
        SELECT DISTINCT sa.user_id, q.quiz_id, q.tenant_id
        FROM student_answers sa
        INNER JOIN questions q ON q.id = sa.question_id
      SQL

      pairs.each do |row|
        user_id = row["user_id"]
        quiz_id = row["quiz_id"]
        tenant_id = row["tenant_id"]

        quiz = Quiz.find_by(id: quiz_id)
        next unless quiz

        timestamps = StudentAnswer
          .joins(:question)
          .where(user_id: user_id, questions: { quiz_id: quiz_id })
          .pick(Arel.sql("MIN(student_answers.created_at)"), Arel.sql("MAX(student_answers.updated_at)"))

        started_at, submitted_at = timestamps
        next unless started_at

        time_limit = quiz.lesson&.quiz_time_limit_seconds || 600
        duration = submitted_at ? (submitted_at - started_at).to_i : nil

        attempt = QuizAttempt.create!(
          tenant_id: tenant_id,
          user_id: user_id,
          quiz_id: quiz_id,
          attempt_number: 1,
          started_at: started_at,
          submitted_at: submitted_at,
          duration_seconds: duration,
          time_limit_seconds: time_limit
        )

        StudentAnswer
          .joins(:question)
          .where(user_id: user_id, questions: { quiz_id: quiz_id })
          .update_all(quiz_attempt_id: attempt.id)
      end
    end
  end
end
