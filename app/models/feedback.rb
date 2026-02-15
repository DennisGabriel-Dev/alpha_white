# frozen_string_literal: true

# == Schema Information
#
# Table name: feedbacks(Student feedback on a lesson (rating + description).)
#
#  id          :bigint           not null, primary key
#  description :text
#  rating      :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  lesson_id   :bigint           not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_feedbacks_on_lesson_id              (lesson_id)
#  index_feedbacks_on_lesson_id_and_user_id  (lesson_id,user_id) UNIQUE
#  index_feedbacks_on_user_id                (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (lesson_id => lessons.id)
#  fk_rails_...  (user_id => users.id)
#
class Feedback < ApplicationRecord
  belongs_to :lesson
  belongs_to :user

  validates :rating, presence: true, numericality: { only_integer: true, in: 1..5 }
  validates :lesson_id, uniqueness: { scope: :user_id, message: "já possui feedback seu" }
end
