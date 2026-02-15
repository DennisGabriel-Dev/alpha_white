class CreateQuestionOptions < ActiveRecord::Migration[8.1]
  def change
    create_table :question_options, comment: "Dynamic alternatives for a question. Only one can be correct." do |t|
      t.references :question, null: false, foreign_key: true
      t.text :text, null: false
      t.boolean :correct, default: false, null: false
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :question_options, [:question_id, :position]
  end
end

