# frozen_string_literal: true

# == Schema Information
#
# Table name: lesson_completions(Lesson completion record by the student (quiz done, video watched).)
#
#  id             :bigint           not null, primary key
#  quiz_completed :boolean          default(FALSE), not null
#  video_watched  :boolean          default(FALSE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  lesson_id      :bigint           not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_lesson_completions_on_lesson_id              (lesson_id)
#  index_lesson_completions_on_lesson_id_and_user_id  (lesson_id,user_id) UNIQUE
#  index_lesson_completions_on_user_id                (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (lesson_id => lessons.id)
#  fk_rails_...  (user_id => users.id)
#
class LessonCompletion < ApplicationRecord
  belongs_to :lesson
  belongs_to :user

  validates :lesson_id, uniqueness: { scope: :user_id }

  def completed?
    completed_quiz? && watched_video?
  end

  def completed_quiz?
    quiz_completed || lesson.quiz.blank?
  end

  def watched_video?
    video_watched || lesson.video_url.blank?
  end
end
