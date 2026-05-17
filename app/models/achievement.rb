class Achievement < ApplicationRecord
  has_many :user_achievements, dependent: :destroy
  has_many :users, through: :user_achievements

  has_one_attached :badge_image

  enum :kind, { event: 0, streak: 1, quiz_perfect: 2 }

  validates :slug, presence: true, uniqueness: true
  validates :name, :description, presence: true
  validates :threshold, numericality: { only_integer: true, greater_than: 0 }
end
