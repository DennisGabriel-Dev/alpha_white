class EnemQuestion < ApplicationRecord
  AREA_VALUES = %w[LC CH CN MT].freeze
  LETTER_VALUES = ("A".."E").map(&:freeze).freeze

  belongs_to :enem_exam

  validates :number_in_exam, presence: true,
                             numericality: { only_integer: true, greater_than: 0 }
  validates :area, presence: true, inclusion: { in: AREA_VALUES }
  validates :statement, presence: true
  validates :correct_letter, presence: true, inclusion: { in: LETTER_VALUES }
  validates :number_in_exam, uniqueness: { scope: :enem_exam_id }

  validate :alternatives_must_be_array

  default_scope { order(number_in_exam: :asc, id: :asc) }

  private

  def alternatives_must_be_array
    return if alternatives.nil?

    errors.add(:alternatives, :invalid) unless alternatives.is_a?(Array)
  end
end
