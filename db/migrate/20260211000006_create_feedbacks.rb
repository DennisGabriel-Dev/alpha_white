class CreateFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks, comment: "Student feedback on a lesson (rating + description)." do |t|
      t.references :lesson, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text :description

      t.timestamps
    end

    add_index :feedbacks, [:lesson_id, :user_id], unique: true
  end
end
