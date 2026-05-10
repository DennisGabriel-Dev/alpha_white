class EnemExam < ApplicationRecord
  DAY_VALUES = %w[D1 D2].freeze

  has_many :enem_questions, dependent: :destroy

  validates :year, presence: true,
                   numericality: { only_integer: true, greater_than: 1990, less_than: 2100 }
  validates :day, presence: true, inclusion: { in: DAY_VALUES }
  validates :booklet_color, presence: true
  validates :year, uniqueness: { scope: %i[day booklet_color] }

  validate :booklet_color_format

  private

  def booklet_color_format
    return if booklet_color.blank?

    errors.add(:booklet_color, :invalid) unless booklet_color.match?(/\ACD\d+\z/i)
  end
end
