# frozen_string_literal: true

# == Schema Information
#
# Table name: quizzes(Quizzes associated with a lesson.)
#
#  id         :bigint           not null, primary key
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  lesson_id  :bigint           not null
#  tenant_id  :bigint           not null
#
# Indexes
#
#  index_quizzes_on_lesson_id         (lesson_id)
#  index_quizzes_on_tenant_id         (tenant_id)
#  index_quizzes_on_tenant_id_and_id  (tenant_id,id)
#
# Foreign Keys
#
#  fk_rails_...  (lesson_id => lessons.id)
#  fk_rails_...  (tenant_id => tenants.id)
#
class Quiz < ApplicationRecord
  acts_as_tenant :tenant

  belongs_to :lesson, inverse_of: :quiz
  belongs_to :tenant
  has_many :questions, dependent: :destroy

  before_validation :set_tenant_from_lesson, on: :create

  validates :title, presence: true

  private

  def set_tenant_from_lesson
    self.tenant_id ||= lesson&.tenant_id
  end
end
