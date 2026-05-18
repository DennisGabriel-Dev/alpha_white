# frozen_string_literal: true

class LessonCompletionsController < ApplicationController
  include GamificationFlash

  before_action :authenticate_user!
  before_action :set_course
  before_action :set_session
  before_action :set_lesson

  def create
    @completion = @lesson.lesson_completions.find_or_initialize_by(user: current_user)
    if @completion.update(lesson_completion_params)
      gamification = nil
      gamification = run_gamification!(lesson_just_completed: @completion.completed?) if current_user.student?
      notice = notice_with_gamification("Progresso registrado.", gamification)
      redirect_to course_session_lesson_path(@course, @session, @lesson), notice: notice
    else
      redirect_to course_session_lesson_path(@course, @session, @lesson), alert: "Erro ao registrar progresso."
    end
  end

  def update
    create
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

  def lesson_completion_params
    params.require(:lesson_completion).permit(:quiz_completed, :video_watched)
  end
end