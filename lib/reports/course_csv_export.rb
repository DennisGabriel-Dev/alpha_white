# frozen_string_literal: true

require "csv"

module Reports
  class CourseCsvExport
    HEADERS = [
      "email",
      "curso",
      "sessao",
      "aula",
      "quiz",
      "questao_posicao",
      "enunciado_resumo",
      "area_enem",
      "acertou",
      "alternativa_marcada",
      "tempo_questao_seg",
      "tempo_prova_seg",
      "tentativa_numero",
      "tentativas_questao",
      "prova_iniciada_em",
      "prova_enviada_em",
      "aula_concluida"
    ].freeze

    def initialize(course:, tenant:, from: nil, to: nil)
      @course = course
      @tenant = tenant
      @period = PeriodFilter.new(from:, to:)
    end

    def call
      CSV.generate(headers: true, col_sep: ";", encoding: "UTF-8") do |csv|
        csv << HEADERS
        rows.each { |row| csv << row }
      end
    end

    private

    def rows
      answers.map { |answer| build_row(answer) }
    end

    def answers
      quiz_ids = Quiz.joins(lesson: :session).where(sessions: { course_id: @course.id }).pluck(:id)
      return [] if quiz_ids.empty?

      scope = StudentAnswer
        .joins(:quiz_attempt, :user, :question_option, question: { quiz: { lesson: :session } })
        .merge(QuizAttempt.submitted)
        .where(quiz_attempts: { quiz_id: quiz_ids })
        .where(users: { tenant_id: @tenant.id, role: :student })
        .includes(
          :user,
          :question_option,
          question: [:enem_question, { quiz: { lesson: :session } }],
          quiz_attempt: :quiz
        )
        .order("users.email ASC, sessions.position ASC, lessons.position ASC, questions.position ASC, quiz_attempts.attempt_number ASC")

      @period.apply_to_quiz_attempts(scope)
    end

    def build_row(answer)
      question = answer.question
      attempt = answer.quiz_attempt
      lesson = question.quiz.lesson
      session = lesson.session
      completion = LessonCompletion.find_by(user: answer.user, lesson: lesson)

      [
        answer.user.email,
        @course.name,
        session.name,
        lesson.name,
        question.quiz.title,
        question.position + 1,
        question.enunciation.to_s.truncate(120),
        question.enem_question&.area,
        answer.question_option.correct? ? "sim" : "nao",
        answer.question_option.text.to_s.truncate(80),
        answer.time_spent_seconds,
        attempt.duration_seconds,
        attempt.attempt_number,
        StudentAnswer.attempt_count_for(user: answer.user, question: question),
        attempt.started_at&.iso8601,
        attempt.submitted_at&.iso8601,
        completion&.completed? ? "sim" : "nao"
      ]
    end
  end
end
