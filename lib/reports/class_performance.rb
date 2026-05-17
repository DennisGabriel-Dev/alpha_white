module Reports
  class ClassPerformance
    WrongRow = Struct.new(:question, :wrong_count, keyword_init: true)
    StudentRow = Struct.new(:user, :completed, :total, :percent, keyword_init: true)
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
        .joins(:question_option, :question)
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

      User.where(tenant_id: @tenant.id, role: :student).order(:email).map do |u|
        completions = LessonCompletion.where(user: u, lesson_id: lesson_ids).includes(:lesson)
        done = completions.count(&:completed?)
        percent = (100.0 * done / total).round(1)
        StudentRow.new(user: u, completed: done, total: total, percent: percent)
      end
    end
  end
end
