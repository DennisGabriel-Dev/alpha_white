class UserAchievement < ApplicationRecord
  acts_as_tenant :tenant

  belongs_to :user
  belongs_to :achievement
  belongs_to :tenant

  validates :achievement_id, uniqueness: { scope: %i[tenant_id user_id] }
  validates :awarded_at, presence: true

  before_validation :set_tenant_from_user, on: :create
  before_validation :set_awarded_at, on: :create

  private

  def set_tenant_from_user
    self.tenant_id ||= user&.tenant_id
  end

  def set_awarded_at
    self.awarded_at ||= Time.current
  end
end
