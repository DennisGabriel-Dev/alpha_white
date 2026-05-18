module Gamification
  class QuizPerfectChecker
    def self.perfect?(quiz, user)
      questions = quiz.questions.to_a
      return false if questions.empty?

      questions.all? do |question|
        answer = question.student_answers.find_by(user: user)
        answer&.question_option&.correct?
      end
    end
  end
end
