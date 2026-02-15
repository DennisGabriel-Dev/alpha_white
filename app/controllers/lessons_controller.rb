# frozen_string_literal: true

class LessonsController < ApplicationController
  include ApiAuthorizable

  before_action :authenticate_user!
  before_action :set_course
  before_action :set_session
  before_action :set_lesson, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_admin_or_instructor!, only: [ :new, :create, :edit, :update, :destroy ]

  def show
    @feedbacks = @lesson.feedbacks
    @my_feedback = @feedbacks.find_by(user: current_user)
    @feedbacks = @feedbacks.where.not(id: @my_feedback&.id)
  end

  def new
    @lesson = @session.lessons.build
  end

  def create
    @lesson = @session.lessons.build(lesson_params)
    if @lesson.save
      redirect_to course_session_path(@course, @session), notice: "Aula criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @lesson.update(lesson_params)
      redirect_to course_session_path(@course, @session), notice: "Aula atualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @lesson.destroy
    redirect_to course_session_path(@course, @session), notice: "Aula removida com sucesso."
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
    params.require(:lesson).permit(:name, :description, :video_url, :position)
  end
end
