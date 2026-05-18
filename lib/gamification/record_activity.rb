module Gamification
  class RecordActivity
    def initialize(user:, tenant:)
      @user = user
      @tenant = tenant
    end

    def call
      return nil unless @user.student?

      ActsAsTenant.with_tenant(@tenant) do
        streak = StudyStreak.find_or_initialize_by(user: @user, tenant: @tenant)
        today = Time.zone.today
        yesterday = today - 1

        if streak.last_activity_on == today
          # already counted today
        elsif streak.last_activity_on == yesterday
          streak.current_streak += 1
        else
          streak.current_streak = 1
        end

        streak.last_activity_on = today
        streak.longest_streak = [streak.longest_streak, streak.current_streak].max
        streak.save!
        streak
      end
    end
  end
end
