# frozen_string_literal: true

class Api::V1::QuizzesController < Api::V1::BaseController
  before_action :set_lesson
  before_action :set_quiz, only: [:show, :update, :destroy]
  before_action :authorize_admin_or_instructor!, only: [:create, :update, :destroy]

  def index
    @quizzes = @lesson.quiz ? [@lesson.quiz] : []
    render json: { quizzes: @quizzes, total: @quizzes.count }
  end

  def show
    render json: { quiz: @quiz }
  end

  def create
    @quiz = @lesson.build_quiz(quiz_params)
    if @quiz.save
      render json: { quiz: @quiz, message: "Prova criada com sucesso." }, status: :created
    else
      render json: { errors: @quiz.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    if @quiz.update(quiz_params)
      render json: { quiz: @quiz, message: "Prova atualizada com sucesso." }
    else
      render json: { errors: @quiz.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    @quiz.destroy
    render json: { message: "Prova removida com sucesso." }
  end

  private

  def set_lesson
    @lesson = Lesson.joins(session: :course).where(courses: { tenant_id: ActsAsTenant.current_tenant.id }).find(params[:lesson_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Aula não encontrada" }, status: :not_found
  end

  def set_quiz
    @quiz = Quiz.find_by(id: params[:id], lesson: @lesson)
    render json: { error: "Prova não encontrada" }, status: :not_found unless @quiz
  end

  def quiz_params
    params.require(:quiz).permit(:title)
  end
end
