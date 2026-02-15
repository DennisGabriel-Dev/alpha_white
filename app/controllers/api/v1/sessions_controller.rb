# frozen_string_literal: true

# API V1 - Sessions Controller (sessões de um curso)
# Apenas Admin ou Instrutor podem create/update/destroy
class Api::V1::SessionsController < Api::V1::BaseController
  before_action :set_course
  before_action :set_session, only: [ :show, :update, :destroy ]
  before_action :authorize_admin_or_instructor!, only: [ :create, :update, :destroy ]

  # GET /api/v1/courses/:course_id/sessions
  def index
    @sessions = @course.sessions
    render json: {
      sessions: @sessions,
      total: @sessions.count,
      _links: hateoas_course_links(@course)
    }
  end

  # GET /api/v1/courses/:course_id/sessions/:id
  def show
    render json: {
      session: @session,
      _links: hateoas_session_links(@course, @session)
    }
  end

  # POST /api/v1/courses/:course_id/sessions
  def create
    @session = @course.sessions.build(session_params)

    if @session.save
      render json: {
        session: @session,
        message: "Sessão criada com sucesso."
      }, status: :created
    else
      render json: {
        errors: @session.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/courses/:course_id/sessions/:id
  def update
    if @session.update(session_params)
      render json: {
        session: @session,
        message: "Sessão atualizada com sucesso."
      }
    else
      render json: {
        errors: @session.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/courses/:course_id/sessions/:id
  def destroy
    if @session.destroy
      render json: { message: "Sessão removida com sucesso." }
    else
      render json: { errors: [ "Erro ao remover sessão" ] }, status: :unprocessable_entity
    end
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Curso não encontrado" }, status: :not_found
  end

  def set_session
    @session = @course.sessions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Sessão não encontrada" }, status: :not_found
  end

  def session_params
    params.require(:session).permit(:name, :position)
  end
end
