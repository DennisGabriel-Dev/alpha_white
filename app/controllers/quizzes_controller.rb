# frozen_string_literal: true

class QuizzesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_instructor!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_course
  before_action :set_session
  before_action :set_lesson
  before_action :set_quiz, only: [:edit, :update, :destroy, :take, :submit]

  def take
    @quiz = @lesson.quiz
    redirect_to course_session_lesson_path(@course, @session, @lesson), alert: "Prova não encontrada" unless @quiz
  end

  def submit
    @quiz = @lesson.quiz
    unless @quiz
      redirect_to course_session_lesson_path(@course, @session, @lesson), alert: "Prova não encontrada"
      return
    end

    answered = 0
    params[:answers]&.each do |question_id, question_option_id|
      next if question_option_id.blank?

      question = @quiz.questions.find_by(id: question_id)
      option = question&.question_options&.find_by(id: question_option_id)
      next unless question && option

      answer = question.student_answers.find_or_initialize_by(user: current_user)
      if answer.update(question_option_id: option.id)
        answered += 1
      end
    end

    completion = @lesson.lesson_completions.find_or_initialize_by(user: current_user)
    question_ids = @quiz.questions.ids
    if question_ids.any?
      answered_for_quiz = StudentAnswer.where(user: current_user, question_id: question_ids).distinct.count(:question_id)
      completion.quiz_completed = true if answered_for_quiz >= question_ids.size
    end
    completion.save!

    lesson_path = course_session_lesson_path(@course, @session, @lesson, tab: "quiz")

    notice = if completion.quiz_completed?
              "Prova concluída! Suas respostas foram registradas."
            else
              "Respostas enviadas (#{answered} nesta submissão). Responda todas as questões para concluir a prova."
            end

    redirect_to lesson_path, notice: notice
  end

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
