# frozen_string_literal: true

class Api::V1::QuestionsController < Api::V1::BaseController
  before_action :set_quiz
  before_action :set_question, only: [:show, :update, :destroy]
  before_action :authorize_admin_or_instructor!, only: [:create, :update, :destroy]

  def index
    @questions = @quiz.questions.includes(:question_options)
    render json: {
      questions: @questions.map { |question| serialize_question(question) },
      total: @questions.count
    }
  end

  def show
    render json: {
      question: serialize_question(@question),
      question_options: serialize_question_options(@question.question_options)
    }
  end

  def create
    @question = @quiz.questions.build(question_params)
    if @question.save
      render json: { question: @question, message: "Questão criada com sucesso." }, status: :created
    else
      render json: { errors: @question.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @question.update(question_params)
      render json: { question: @question, message: "Questão atualizada com sucesso." }
    else
      render json: { errors: @question.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @question.destroy
    render json: { message: "Questão removida com sucesso." }
  end

  private

  def set_quiz
    @quiz = Quiz.joins(lesson: { session: :course }).where(courses: { tenant_id: ActsAsTenant.current_tenant.id }).find(params[:quiz_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Prova não encontrada" }, status: :not_found
  end

  def set_question
    @question = @quiz.questions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Questão não encontrada" }, status: :not_found
  end

  def question_params
    params.require(:question).permit(
      :enunciation, :position,
      question_options_attributes: [:id, :text, :correct, :position, :_destroy]
    )
  end
end
