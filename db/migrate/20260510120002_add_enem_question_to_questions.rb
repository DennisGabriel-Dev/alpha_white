class AddEnemQuestionToQuestions < ActiveRecord::Migration[8.1]
  def change
    add_reference :questions, :enem_question, null: true, foreign_key: true
    add_index :questions, %i[tenant_id enem_question_id]
  end
end
