# frozen_string_literal: true

class QuizzesController < ApplicationController
  include ApiAuthorizable

  before_action :authenticate_user!
  before_action :set_course
  before_action :set_session
  before_action :set_lesson
  before_action :set_quiz, only: [:edit, :update, :destroy]
  before_action :authorize_admin_or_instructor!, only: [:new, :create, :edit, :update, :destroy]

  def new
    redirect_to edit_course_session_lesson_quiz_path(@course, @session, @lesson) if @lesson.quiz.present?
    @quiz = @lesson.build_quiz
  end

  def create
    @quiz = @lesson.build_quiz(quiz_params)
    if @quiz.save
      redirect_to course_session_lesson_quiz_questions_path(@course, @session, @lesson),
                  notice: "Prova criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @quiz.update(quiz_params)
      redirect_to course_session_lesson_quiz_questions_path(@course, @session, @lesson),
                  notice: "Prova atualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @quiz.destroy
    redirect_to course_session_lesson_path(@course, @session, @lesson),
                notice: "Prova removida com sucesso."
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_session
    @session = @course.sessions.find(params[:session_id])
  end

  def set_lesson
    @lesson = @session.lessons.find(params[:lesson_id])
  end

  def set_quiz
    @quiz = @lesson.quiz
    redirect_to course_session_lesson_path(@course, @session, @lesson), alert: "Prova não encontrada" unless @quiz
  end

  def quiz_params
    params.require(:quiz).permit(:title)
  end
end