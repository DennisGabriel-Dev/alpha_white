class CreateEnemQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :enem_questions, comment: "Official ENEM question (global library)." do |t|
      t.references :enem_exam, null: false, foreign_key: true
      t.integer :number_in_exam, null: false
      t.string :area, null: false, comment: "LC, CH, CN, MT"
      t.string :skill
      t.text :statement, null: false
      t.jsonb :alternatives, null: false, default: []
      t.string :correct_letter, null: false

      t.timestamps
    end

    add_index :enem_questions, %i[enem_exam_id number_in_exam], unique: true,
              name: "index_enem_questions_on_exam_and_number"
    add_index :enem_questions, :area
  end
end
