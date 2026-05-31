# frozen_string_literal: true

class AddQuizTimeLimitToLessons < ActiveRecord::Migration[8.1]
  def change
    add_column :lessons, :quiz_time_limit_seconds, :integer, null: false, default: 600,
               comment: "Limit of time for the quiz of this lesson (seconds). Default: 10 min."
  end
end
