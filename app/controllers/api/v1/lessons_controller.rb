# frozen_string_literal: true

class Api::V1::LessonsController < Api::V1::BaseController
  before_action :set_course
  before_action :set_session
  before_action :set_lesson, only: [:show, :update, :destroy]
  before_action :authorize_admin_or_instructor!, only: [:create, :update, :destroy]

  def index
    @lessons = @session.lessons
    render json: {
      lessons: @lessons,
      total: @lessons.count,
      _links: hateoas_session_links(@course, @session)
    }
  end

  def show
    render json: {
      lesson: @lesson,
      _links: hateoas_lesson_links(@course, @session, @lesson)
    }
  end

  def create
    @lesson = @session.lessons.build(lesson_params)
    if @lesson.save
      render json: { lesson: @lesson, message: "Aula criada com sucesso." }, status: :created
    else
      render json: { errors: @lesson.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @lesson.update(lesson_params)
      render json: { lesson: @lesson, message: "Aula atualizada com sucesso." }
    else
      render json: { errors: @lesson.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @lesson.destroy
    render json: { message: "Aula removida com sucesso." }
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Curso não encontrado" }, status: :not_found
  end

  def set_session
    @session = Session.joins(:course).where(courses: { tenant_id: ActsAsTenant.current_tenant.id, id: params[:course_id] }).find(params[:session_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Sessão não encontrada" }, status: :not_found
  end

  def set_lesson
    @lesson = @session.lessons.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Aula não encontrada" }, status: :not_found
  end

  def lesson_params
    params.require(:lesson).permit(:name, :description, :video_url, :position)
  end
end
