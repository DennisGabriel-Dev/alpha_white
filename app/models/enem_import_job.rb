class EnemImportJob < ApplicationRecord
  acts_as_tenant :tenant

  enum :status, { pending: 0, processing: 1, done: 2, failed: 3 }, default: :pending

  belongs_to :user
  belongs_to :tenant
  belongs_to :enem_exam, optional: true

  has_one_attached :exam_pdf
  has_one_attached :answer_key_pdf

  validates :exam_pdf, presence: true
  validates :answer_key_pdf, presence: true

  before_validation :set_tenant_from_user, on: :create

  def mark_processing!
    update!(status: :processing, error_message: nil)
  end

  def mark_done!(exam:)
    update!(status: :done, enem_exam: exam, error_message: nil)
  end

  def mark_failed!(message)
    update!(status: :failed, error_message: message.to_s.truncate(1000))
  end

  private

  def set_tenant_from_user
    self.tenant_id ||= user&.tenant_id
  end
end
