module AchievementsHelper
  DEFAULT_BADGE_PATH = "achievements/default.png"

  def achievement_badge_image(achievement, css_class: "w-16 h-16 object-contain mx-auto")
    badge_image = if achievement.badge_image.attached?
      achievement.badge_image
    else
      DEFAULT_BADGE_PATH
    end
    image_tag badge_image, class: css_class, alt: achievement.name
  end

  def student_streak_display
    return nil unless user_signed_in? && current_user.student?

    streak = current_user.study_streak_for(current_tenant)
    streak&.current_streak.to_i
  end
end
