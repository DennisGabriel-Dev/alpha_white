# frozen_string_literal: true

class LessonsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_instructor!, only: [ :new, :create, :edit, :update, :destroy, :destroy_video ]
  before_action :set_course
  before_action :set_session
  before_action :set_lesson, only: [ :show, :edit, :update, :destroy, :destroy_video ]

  def show
    @feedbacks = @lesson.feedbacks.includes(:user)
    @my_feedback = @feedbacks.find_by(user: current_user)
    @feedbacks = @feedbacks.where.not(id: @my_feedback&.id)

    @sessions   = @course.sessions.order(:position).includes(:lessons)
    @all_lessons = @sessions.flat_map(&:lessons)
    @completions = LessonCompletion
      .where(user: current_user, lesson: @all_lessons)
      .index_by(&:lesson_id)
  end

  def new
    @lesson = @session.lessons.build
  end

  def create
    @lesson = @session.lessons.build(lesson_params)
    if @lesson.save
      redirect_to course_session_path(@course, @session), notice: "Aula criada com sucesso."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @lesson.update(lesson_params)
      redirect_after_lesson_update("Aula atualizada com sucesso.")
    elsif params[:return_to] == "quiz_questions" && @lesson.quiz.present?
      redirect_to course_session_lesson_quiz_questions_path(@course, @session, @lesson),
                  alert: @lesson.errors.full_messages.to_sentence
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @lesson.destroy
    redirect_to course_session_path(@course, @session), notice: "Aula removida com sucesso."
  end

  def destroy_video
    @lesson.video.purge
    redirect_to edit_course_session_lesson_path(@course, @session, @lesson), notice: "Vídeo removido com sucesso."
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_session
    @session = @course.sessions.find(params[:session_id])
  end

  def set_lesson
    @lesson = @session.lessons.find(params[:id])
  end

  def lesson_params
    params.require(:lesson).permit(:name, :description, :video_url, :position, :video, :quiz_time_limit_minutes)
  end

  def redirect_after_lesson_update(default_notice)
    if params[:return_to] == "quiz_questions" && @lesson.quiz.present?
      redirect_to course_session_lesson_quiz_questions_path(@course, @session, @lesson),
                  notice: "Tempo da prova atualizado."
    else
      redirect_to course_session_path(@course, @session), notice: default_notice
    end
  end
end
