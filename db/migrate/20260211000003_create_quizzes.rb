class CreateQuizzes < ActiveRecord::Migration[8.1]
  def change
    create_table :quizzes, comment: "Quizzes associated with a lesson." do |t|
      t.references :lesson, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: true
      t.string :title, null: false

      t.timestamps
    end

    add_index :quizzes, [ :tenant_id, :id ]
  end
end
