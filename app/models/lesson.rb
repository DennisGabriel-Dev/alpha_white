# frozen_string_literal: true

# == Schema Information
#
# Table name: lessons(Lessons inside a session. Each lesson can have a video, description and quizzes.)
#
#  id          :bigint           not null, primary key
#  description :text
#  name        :string           not null
#  position    :integer          default(0), not null
#  video_url   :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  session_id  :bigint           not null
#  tenant_id   :bigint           not null
#
# Indexes
#
#  index_lessons_on_session_id               (session_id)
#  index_lessons_on_session_id_and_position  (session_id,position)
#  index_lessons_on_tenant_id                (tenant_id)
#  index_lessons_on_tenant_id_and_id         (tenant_id,id)
#
# Foreign Keys
#
#  fk_rails_...  (session_id => sessions.id)
#  fk_rails_...  (tenant_id => tenants.id)
#
class Lesson < ApplicationRecord
  acts_as_tenant :tenant

  belongs_to :session
  belongs_to :tenant
  has_one :quiz, dependent: :destroy, inverse_of: :lesson
  has_one_attached :video
  has_many :feedbacks, dependent: :destroy
  has_many :lesson_completions, dependent: :destroy

  before_validation :set_tenant_from_session, on: :create

  validates :name, presence: true

  default_scope { order(position: :asc, id: :asc) }

  def video_prerequisite_met_for?(user)
    return true unless video.attached? || video_url.present?

    lesson_completions.find_by(user: user)&.video_watched?
  end

  private

  def set_tenant_from_session
    self.tenant_id ||= session&.tenant_id
  end
end
