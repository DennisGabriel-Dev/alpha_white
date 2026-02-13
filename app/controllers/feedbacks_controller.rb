# frozen_string_literal: true

class FeedbacksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course
  before_action :set_session
  before_action :set_lesson

  def create
    @feedback = @lesson.feedbacks.build(feedback_params.merge(user: current_user))
    if @feedback.save
      redirect_to course_session_lesson_path(@course, @session, @lesson), notice: "Feedback enviado com sucesso."
    else
      render "lessons/show", status: :unprocessable_entity
    end
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

  def feedback_params
    params.require(:feedback).permit(:rating, :description)
  end
end