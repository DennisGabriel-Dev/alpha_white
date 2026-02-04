class Course < ApplicationRecord
  acts_as_tenant :tenant

  belongs_to :tenant

  validates :name, presence: true
  validates :description, length: { maximum: 1000 }

  scope :active, -> { where(active: true) }
end
