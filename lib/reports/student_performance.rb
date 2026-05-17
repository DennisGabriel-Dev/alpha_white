# frozen_string_literal: true

module Reports
  # Desempenho do aluno: progresso por curso + acertos por área ENEM (questões com enem_question).
  class StudentPerformance
    CourseRow = Struct.new(:course, :completed, :total, :percent, keyword_init: true)
    EnemRow = Struct.new(:area, :correct, :total, :percent, keyword_init: true)
    Result = Struct.new(:course_rows, :enem_rows, keyword_init: true)

    def initialize(user:, tenant:)
      @user = user
      @tenant = tenant
    end

    def call
      Result.new(course_rows: build_course_rows, enem_rows: build_enem_rows)
    end

    private

    def build_course_rows
      ActsAsTenant.with_tenant(@tenant) do
        Course.active.includes(sessions: :lessons).filter_map do |course|
          lessons = course.lessons.to_a
          next if lessons.empty?

          total = lessons.size
          lesson_ids = lessons.map(&:id)
          completions = LessonCompletion.where(user: @user, lesson_id: lesson_ids).includes(:lesson)
          done = completions.count(&:completed?)
          percent = total.positive? ? (100.0 * done / total).round(1) : 0.0

          CourseRow.new(course: course, completed: done, total: total, percent: percent)
        end
      end
    end

    def build_enem_rows
      answers = StudentAnswer.joins(question: :enem_question).where(user: @user).includes(
        :question_option,
        question: { enem_question: :enem_exam }
      )

      by_area = answers.group_by { |a| a.question.enem_question.area }
      by_area.map do |area, arr|
        correct = arr.count { |a| a.question_option&.correct? }
        total = arr.size
        percent = total.positive? ? (100.0 * correct / total).round(1) : 0.0
        EnemRow.new(area: area, correct: correct, total: total, percent: percent)
      end.sort_by(&:area)
    end
  end
end
