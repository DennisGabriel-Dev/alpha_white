module Gamification
  module AchievementsCatalog
    ROWS = [
      {
        slug: "first_answer",
        name: "Primeira resposta",
        description: "Respondeu sua primeira questão em uma prova.",
        kind: :event,
        threshold: 1
      },
      {
        slug: "first_lesson_done",
        name: "Primeira aula concluída",
        description: "Concluiu sua primeira aula (vídeo e prova, quando houver).",
        kind: :event,
        threshold: 1
      },
      {
        slug: "streak_3",
        name: "Fogo no estudo (3 dias)",
        description: "Estudou por 3 dias seguidos.",
        kind: :streak,
        threshold: 3
      },
      {
        slug: "streak_7",
        name: "Semana de foco (7 dias)",
        description: "Manteve a sequência de estudo por 7 dias.",
        kind: :streak,
        threshold: 7
      },
      {
        slug: "quiz_perfect",
        name: "Prova perfeita",
        description: "Acertou todas as questões de uma prova.",
        kind: :quiz_perfect,
        threshold: 1
      }
    ].freeze

    module_function

    def ensure!
      ROWS.each do |row|
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
end
