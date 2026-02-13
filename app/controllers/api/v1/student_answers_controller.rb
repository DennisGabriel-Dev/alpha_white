# frozen_string_literal: true

# Estudante envia resposta a uma questão
class Api::V1::StudentAnswersController < Api::V1::BaseController
  before_action :set_question

  def index
    @answers = @question.student_answers.where(user: current_user)
    render json: { student_answers: @answers, total: @answers.count }
  end

  def create
    @answer = @question.student_answers.find_or_initialize_by(user: current_user)
    if @answer.update(student_answer_params)
      render json: { student_answer: @answer, message: "Resposta enviada com sucesso." }, status: @answer.previously_new_record? ? :created : :ok
    else
      render json: { errors: @answer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @answer = @question.student_answers.find_by!(user: current_user)
    if @answer.update(student_answer_params)
      render json: { student_answer: @answer, message: "Resposta atualizada com sucesso." }
    else
      render json: { errors: @answer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_question
    @question = Question.joins(quiz: { lesson: { session: :course } }).where(courses: { tenant_id: ActsAsTenant.current_tenant.id }).find(params[:question_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Questão não encontrada" }, status: :not_found
  end

  def student_answer_params
    params.require(:student_answer).permit(:answer, :selected_option, :question_option_id)
  end
end
