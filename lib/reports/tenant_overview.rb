module Reports
  class TenantOverview
    EngagementRow = Struct.new(:course, :active_students_7d, keyword_init: true)
    Result = Struct.new(:active_student_count, :engagement_rows, keyword_init: true)

    WINDOW_DAYS = 7
    WINDOW = WINDOW_DAYS.days

    def initialize(tenant:)
      @tenant = tenant
    end

    def call
      Result.new(
        active_student_count: count_active_students,
        engagement_rows: build_engagement
      )
    end

    private

    def since
      WINDOW.ago
    end

    def count_active_students
      from_lc = LessonCompletion.joins(:lesson).where(lessons: { tenant_id: @tenant.id }).where("lesson_completions.updated_at >= ?", since).pluck(:user_id)
      from_sa = StudentAnswer.joins(:question).where(questions: { tenant_id: @tenant.id }).where("student_answers.updated_at >= ?", since).pluck(:user_id)
      ids = (from_lc + from_sa).uniq
      User.where(tenant_id: @tenant.id, role: :student, id: ids).distinct.count(:id)
    end

    def build_engagement
      ActsAsTenant.with_tenant(@tenant) do
        Course.active.includes(:sessions).map do |course|
          lesson_ids = Lesson.joins(:session).where(sessions: { course_id: course.id }).pluck(:id)
          next nil if lesson_ids.empty?

          from_lc = LessonCompletion.where(lesson_id: lesson_ids).where("lesson_completions.updated_at >= ?", since).distinct.pluck(:user_id)
          from_sa = StudentAnswer
            .joins(question: { quiz: :lesson })
            .where(lessons: { id: lesson_ids })
            .where("student_answers.updated_at >= ?", since)
            .distinct
            .pluck(:user_id)
          n = (from_lc + from_sa).uniq.size

          EngagementRow.new(course: course, active_students_7d: n)
        end.compact
      end
    end
  end
end
