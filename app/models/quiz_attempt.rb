# frozen_string_literal: true

class QuizAttempt < ApplicationRecord
  acts_as_tenant :tenant

  belongs_to :user
  belongs_to :quiz
  belongs_to :tenant
  has_many :student_answers, dependent: :destroy

  validates :attempt_number, numericality: { only_integer: true, greater_than: 0 }
  validates :started_at, presence: true
  validates :time_limit_seconds, numericality: { only_integer: true, greater_than: 0 }
  validates :attempt_number, uniqueness: { scope: [:tenant_id, :user_id, :quiz_id] }

  scope :in_progress, -> { where(submitted_at: nil) }
  scope :submitted, -> { where.not(submitted_at: nil) }

  def in_progress?
    submitted_at.nil?
  end

  def expired?
    in_progress? && Time.current > expires_at
  end

  def expires_at
    started_at + time_limit_seconds.seconds
  end

  def submit!(at: Time.current)
    return if submitted_at.present?

    update!(
      submitted_at: at,
      duration_seconds: [ (at - started_at).to_i, 0 ].max
    )
  end
end
