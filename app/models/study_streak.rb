class StudyStreak < ApplicationRecord
  acts_as_tenant :tenant

  belongs_to :user
  belongs_to :tenant

  validates :user_id, uniqueness: { scope: :tenant_id }
  validates :current_streak, :longest_streak, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_validation :set_tenant_from_user, on: :create

  private

  def set_tenant_from_user
    self.tenant_id ||= user&.tenant_id
  end
end
