# frozen_string_literal: true

# == Schema Information
#
# Table name: questions(Questions of a quiz. Each question is the enunciation of the quiz.)
#
#  id             :bigint           not null, primary key
#  correct_answer :string
#  enunciation    :text             not null
#  position       :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  quiz_id        :bigint           not null
#  tenant_id      :bigint           not null
#
# Indexes
#
#  index_questions_on_quiz_id               (quiz_id)
#  index_questions_on_quiz_id_and_position  (quiz_id,position)
#  index_questions_on_tenant_id             (tenant_id)
#  index_questions_on_tenant_id_and_id      (tenant_id,id)
#
# Foreign Keys
#
#  fk_rails_...  (quiz_id => quizzes.id)
#  fk_rails_...  (tenant_id => tenants.id)
#
class Question < ApplicationRecord
  acts_as_tenant :tenant

  belongs_to :quiz
  belongs_to :tenant
  belongs_to :enem_question, optional: true
  has_many :question_options, dependent: :destroy
  has_many :student_answers, dependent: :destroy

  before_validation :set_tenant_from_quiz, on: :create

  validates :enunciation, presence: true
  validate :exactly_one_correct_option

  accepts_nested_attributes_for :question_options, allow_destroy: true, reject_if: proc { |attrs| attrs["text"].blank? }

  default_scope { order(position: :asc, id: :asc) }

  def from_enem?
    enem_question_id.present?
  end

  private

  def exactly_one_correct_option
    opts = question_options.reject(&:marked_for_destruction?)
    return if opts.empty?

    correct_count = opts.count(&:correct)
    errors.add(:base, "must have exactly one correct option") if correct_count != 1
  end

  def set_tenant_from_quiz
    self.tenant_id ||= quiz&.tenant_id
  end
end
