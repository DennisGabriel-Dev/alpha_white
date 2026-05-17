module Me
  class AchievementsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_student!

    def index
      @achievements = Achievement.order(:kind, :threshold, :id)
      earned_ids = current_user.user_achievements.pluck(:achievement_id).to_set
      @earned = current_user.user_achievements.includes(:achievement).index_by(&:achievement_id)
      @earned_ids = earned_ids
    end

    private

    def require_student!
      return if current_user.student?

      redirect_to root_path, alert: "Conquistas disponíveis apenas para alunos."
    end
  end
end
