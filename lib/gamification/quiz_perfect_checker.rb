module Gamification
  class QuizPerfectChecker
    def self.perfect?(quiz, user)
      attempt = quiz.latest_submitted_attempt_for(user)
      return false unless attempt

      questions = quiz.questions.to_a
      return false if questions.empty?

      questions.all? do |question|
        answer = attempt.student_answers.find_by(question: question)
        answer&.question_option&.correct?
      end
    end
  end
end
