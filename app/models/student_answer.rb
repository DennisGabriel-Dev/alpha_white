# frozen_string_literal: true

# == Schema Information
#
# Table name: student_answers(Individual student answer to a question.)
#
#  id                 :bigint           not null, primary key
#  answer             :text
#  selected_option    :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  question_id        :bigint           not null
#  question_option_id :bigint
#  user_id            :bigint           not null
#
# Indexes
#
#  index_student_answers_on_question_id              (question_id)
#  index_student_answers_on_question_id_and_user_id  (question_id,user_id) UNIQUE
#  index_student_answers_on_question_option_id       (question_option_id)
#  index_student_answers_on_user_id                  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_id => questions.id)
#  fk_rails_...  (question_option_id => question_options.id)
#  fk_rails_...  (user_id => users.id)
#
class StudentAnswer < ApplicationRecord
  belongs_to :question
  belongs_to :user
  belongs_to :question_option, optional: true
  belongs_to :quiz_attempt

  validates :question_id, uniqueness: { scope: :quiz_attempt_id }

  def self.latest_for(user:, question:)
    where(user: user, question: question).order(created_at: :desc).first
  end

  def self.attempt_count_for(user:, question:)
    joins(:quiz_attempt)
      .where(user: user, question: question)
      .merge(QuizAttempt.submitted)
      .distinct
      .count("quiz_attempts.id")
  end
end
