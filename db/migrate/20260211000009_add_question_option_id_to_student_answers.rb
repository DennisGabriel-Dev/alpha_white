class AddQuestionOptionIdToStudentAnswers < ActiveRecord::Migration[8.1]
  def change
    add_reference :student_answers, :question_option, foreign_key: true
  end
end