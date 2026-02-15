class CreateLessonCompletions < ActiveRecord::Migration[8.1]
  def change
    create_table :lesson_completions, comment: "Lesson completion record by the student (quiz done, video watched)." do |t|
      t.references :lesson, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.boolean :quiz_completed, default: false, null: false
      t.boolean :video_watched, default: false, null: false

      t.timestamps
    end

    add_index :lesson_completions, [:lesson_id, :user_id], unique: true
  end
end
