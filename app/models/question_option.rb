# frozen_string_literal: true

# == Schema Information
#
# Table name: question_options(Dynamic alternatives for a question. Only one can be correct.)
#
#  id          :bigint           not null, primary key
#  correct     :boolean          default(FALSE), not null
#  position    :integer          default(0), not null
#  text        :text             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  question_id :bigint           not null
#
# Indexes
#
#  index_question_options_on_question_id               (question_id)
#  index_question_options_on_question_id_and_position  (question_id,position)
#
# Foreign Keys
#
#  fk_rails_...  (question_id => questions.id)
#
class QuestionOption < ApplicationRecord
  belongs_to :question
  has_many :student_answers, dependent: :nullify

  validates :text, presence: true

  default_scope { order(position: :asc, id: :asc) }
end
