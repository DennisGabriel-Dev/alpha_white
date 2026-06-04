# frozen_string_literal: true

module Reports
  class ClassPerformance
    WrongRow = Struct.new(:question, :wrong_count, keyword_init: true)
    StudentRow = Struct.new(
      :user, :completed, :total, :percent, :quiz_time_seconds, :quiz_attempts_count, keyword_init: true
    )
    Result = Struct.new(:top_wrong, :student_rows, keyword_init: true)

    def initialize(tenant:)
      @tenant = tenant
    end

    def call
      Result.new(top_wrong: top_wrong_questions, student_rows: student_progress_rows)
    end

    private

    def top_wrong_questions
      pairs = StudentAnswer
        .joins(:question_option, :question, :quiz_attempt)
        .merge(QuizAttempt.submitted)
        .where(questions: { tenant_id: @tenant.id })
        .where(question_options: { correct: false })
        .group(:question_id)
        .count
        .sort_by { |_qid, n| -n }
        .first(10)
      return [] if pairs.empty?

      qids = pairs.map(&:first)
      questions = Question.where(id: qids).index_by(&:id)

      pairs.filter_map do |qid, n|
        q = questions[qid]
        next unless q

        WrongRow.new(question: q, wrong_count: n)
      end
    end

    def student_progress_rows
      lesson_ids = Lesson.where(tenant_id: @tenant.id).pluck(:id)
      total = lesson_ids.size
      return [] if total.zero?

      quiz_ids = Quiz.where(lesson_id: lesson_ids).pluck(:id)

      User.where(tenant_id: @tenant.id, role: :student).order(:email).map do |u|
        completions = LessonCompletion.where(user: u, lesson_id: lesson_ids).includes(:lesson)
        done = completions.count(&:completed?)
        percent = (100.0 * done / total).round(1)
        attempts = QuizAttempt.submitted.where(user: u, quiz_id: quiz_ids)
        quiz_time_seconds = attempts.sum(:duration_seconds).to_i

        StudentRow.new(
          user: u,
          completed: done,
          total: total,
          percent: percent,
          quiz_time_seconds: quiz_time_seconds,
          quiz_attempts_count: attempts.count
        )
      end
    end
  end
end
