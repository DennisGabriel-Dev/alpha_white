class CreateLessons < ActiveRecord::Migration[8.1]
  def change
    create_table :lessons, comment: "Lessons inside a session. Each lesson can have a video, description and quizzes." do |t|
      t.references :session, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :video_url
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :lessons, [ :tenant_id, :id ]
    add_index :lessons, [ :session_id, :position ]
  end
end
