# frozen_string_literal: true

module Quizzes
  class FinalizeExpiredAttempts
    def initialize(quiz:, user:)
      @quiz = quiz
      @user = user
    end

    def call
      QuizAttempt.in_progress.where(quiz: @quiz, user: @user).find_each do |attempt|
        next unless attempt.expired?

        attempt.submit!(at: attempt.expires_at)
      end
    end
  end
end
