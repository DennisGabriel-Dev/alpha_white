class CreateStudentAnswers < ActiveRecord::Migration[8.1]
  def change
    create_table :student_answers, comment: "Individual student answer to a question." do |t|
      t.references :question, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :answer
      t.string :selected_option

      t.timestamps
    end

    add_index :student_answers, [:question_id, :user_id], unique: true
  end
end
