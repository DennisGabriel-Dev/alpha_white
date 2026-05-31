# frozen_string_literal: true

module Quizzes
  class EnsureAttempt
    def initialize(quiz:, user:)
      @quiz = quiz
      @user = user
    end

    def call
      in_progress = QuizAttempt.in_progress.find_by(quiz: @quiz, user: @user)
      return in_progress if in_progress

      QuizAttempt.create!(
        quiz: @quiz,
        user: @user,
        tenant: @quiz.tenant,
        attempt_number: next_attempt_number,
        started_at: Time.current,
        time_limit_seconds: @quiz.lesson.quiz_time_limit_seconds
      )
    end

    private

    def next_attempt_number
      (QuizAttempt.where(quiz: @quiz, user: @user).maximum(:attempt_number) || 0) + 1
    end
  end
end
