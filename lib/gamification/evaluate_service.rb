module Gamification
  # Avalia streak e badges após atividade do aluno (aula ou prova).
  class EvaluateService
    def initialize(user:, tenant:, quiz: nil, lesson_just_completed: false)
      @user = user
      @tenant = tenant
      @quiz = quiz
      @lesson_just_completed = lesson_just_completed
    end

    def call
      return Gamification::Result.new(newly_awarded: [], study_streak: nil) unless @user.student?

      AchievementsCatalog.ensure! if Achievement.none?

      newly_awarded = []
      streak = nil

      ActsAsTenant.with_tenant(@tenant) do
        streak = RecordActivity.new(user: @user, tenant: @tenant).call
        newly_awarded.concat(evaluate_event_badges)
        newly_awarded.concat(evaluate_streak_badges(streak))
        newly_awarded.concat(evaluate_quiz_perfect) if @quiz
      end

      Gamification::Result.new(newly_awarded: newly_awarded.uniq, study_streak: streak)
    end

    private

    def evaluate_event_badges
      awarded = []

      if first_answer_just_earned?
        a = grant_by_slug("first_answer")
        awarded << a if a
      end

      if @lesson_just_completed && first_lesson_just_earned?
        a = grant_by_slug("first_lesson_done")
        awarded << a if a
      end

      awarded
    end

    def evaluate_streak_badges(streak)
      return [] unless streak

      Achievement.streak.filter_map do |achievement|
        next if already_has?(achievement)
        next if streak.current_streak < achievement.threshold

        grant(achievement)
      end
    end

    def evaluate_quiz_perfect
      return [] unless QuizPerfectChecker.perfect?(@quiz, @user)

      achievement = Achievement.find_by(slug: "quiz_perfect")
      return [] unless achievement
      return [] if already_has?(achievement)

      granted = grant(achievement)
      granted ? [granted] : []
    end

    def first_answer_just_earned?
      return false if already_has_slug?("first_answer")

      student_answers_in_tenant.exists?
    end

    def first_lesson_just_earned?
      return false if already_has_slug?("first_lesson_done")

      LessonCompletion.joins(:lesson)
                      .where(user: @user, lessons: { tenant_id: @tenant.id })
                      .includes(:lesson)
                      .any?(&:completed?)
    end

    def student_answers_in_tenant
      StudentAnswer.joins(:question).where(user: @user, questions: { tenant_id: @tenant.id })
    end

    def already_has_slug?(slug)
      achievement = Achievement.find_by(slug: slug)
      achievement && already_has?(achievement)
    end

    def grant_by_slug(slug)
      achievement = Achievement.find_by(slug: slug)
      return nil unless achievement
      return nil if already_has?(achievement)

      grant(achievement)
    end

    def already_has?(achievement)
      UserAchievement.exists?(user: @user, achievement: achievement, tenant: @tenant)
    end

    def grant(achievement)
      UserAchievement.create!(user: @user, achievement: achievement, tenant: @tenant)
      achievement
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
      nil
    end
  end
end
