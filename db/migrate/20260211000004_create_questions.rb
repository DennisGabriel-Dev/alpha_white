class CreateQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :questions, comment: "Questions of a quiz. Each question is the enunciation of the quiz." do |t|
      t.references :quiz, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: true
      t.text :enunciation, null: false
      t.string :correct_answer
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :questions, [ :tenant_id, :id ]
    add_index :questions, [ :quiz_id, :position ]
  end
end
