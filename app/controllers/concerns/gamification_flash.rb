module GamificationFlash
  extend ActiveSupport::Concern

  private

  def run_gamification!(quiz: nil, lesson_just_completed: false)
    Gamification::EvaluateService.new(
      user: current_user,
      tenant: ActsAsTenant.current_tenant,
      quiz: quiz,
      lesson_just_completed: lesson_just_completed
    ).call
  end

  def notice_with_gamification(base_notice, gamification_result)
    return base_notice if gamification_result.blank? || gamification_result.newly_awarded.blank?

    names = gamification_result.newly_awarded.map(&:name).join(", ")
    [base_notice, "Nova conquista: #{names}."].compact_blank.join(" ")
  end
end
