# frozen_string_literal: true

class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_instructor!, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :set_course
  before_action :set_session
  before_action :set_lesson
  before_action :set_quiz
  before_action :set_question, only: [ :edit, :update, :destroy ]

  def index
    @questions = @quiz.questions.includes(:question_options)
  end

  def new
    @question = @quiz.questions.build
    2.times { @question.question_options.build } if @question.question_options.empty?
  end

  def create
    @question = @quiz.questions.build(question_params)
    if @question.save
      redirect_to course_session_lesson_quiz_questions_path(@course, @session, @lesson),
                  notice: "Questão criada com sucesso."
    else
      2.times { @question.question_options.build } if @question.question_options.reject(&:marked_for_destruction?).empty?
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @question.question_options.build if @question.question_options.empty?
  end

  def update
    if @question.update(question_params)
      redirect_to course_session_lesson_quiz_questions_path(@course, @session, @lesson),
                  notice: "Questão atualizada com sucesso."
    else
      2.times { @question.question_options.build } if @question.question_options.reject(&:marked_for_destruction?).empty?
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @question.destroy
    redirect_to course_session_lesson_quiz_questions_path(@course, @session, @lesson),
                notice: "Questão removida com sucesso."
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

  def set_question
    @question = @quiz.questions.find(params[:id])
  end

  def question_params
    p = params.require(:question).permit(
      :enunciation, :position,
      question_options_attributes: [ :id, :text, :correct, :position, :_destroy ]
    )
    correct_index = params[:correct_option_index]&.to_i
    if correct_index && p[:question_options_attributes]
      p[:question_options_attributes].to_h.each do |k, v|
        v[:correct] = (k.to_s.to_i == correct_index)
      end
    end
    p
  end
end
