# frozen_string_literal: true

module AchievementsCatalogHelper
  CATALOG = [
    { slug: "first_answer", name: "Primeira resposta", description: "d", kind: :event, threshold: 1 },
    { slug: "first_lesson_done", name: "Primeira aula", description: "d", kind: :event, threshold: 1 },
    { slug: "streak_3", name: "3 dias", description: "d", kind: :streak, threshold: 3 },
    { slug: "streak_7", name: "7 dias", description: "d", kind: :streak, threshold: 7 },
    { slug: "quiz_perfect", name: "Perfeita", description: "d", kind: :quiz_perfect, threshold: 1 }
  ].freeze

  def ensure_achievements_catalog!
    CATALOG.each do |row|
      achievement = Achievement.find_or_initialize_by(slug: row[:slug])
      achievement.assign_attributes(
        name: row[:name],
        description: row[:description],
        kind: row[:kind],
        threshold: row[:threshold]
      )
      achievement.save!
    end
  end
end

RSpec.configure do |config|
  config.include AchievementsCatalogHelper
end
