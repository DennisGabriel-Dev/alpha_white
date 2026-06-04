# frozen_string_literal: true

module QuizAnswerHelpers
  def create_submitted_answer(user:, question:, question_option:, started_at: 1.hour.ago, submitted_at: 30.minutes.ago)
    quiz = question.quiz
    attempt_number = (QuizAttempt.where(user: user, quiz: quiz).maximum(:attempt_number) || 0) + 1
    attempt = QuizAttempt.create!(
      tenant: quiz.tenant,
      user: user,
      quiz: quiz,
      attempt_number: attempt_number,
      started_at: started_at,
      submitted_at: submitted_at,
      duration_seconds: (submitted_at - started_at).to_i,
      time_limit_seconds: quiz.lesson.quiz_time_limit_seconds
    )
    StudentAnswer.create!(
      user: user,
      question: question,
      question_option: question_option,
      quiz_attempt: attempt
    )
    attempt
  end
end

RSpec.configure do |config|
  config.include QuizAnswerHelpers
end
