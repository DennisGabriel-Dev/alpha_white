# frozen_string_literal: true

# Controller web para sessões de um curso (HTML)
# Apenas Admin ou Instrutor podem create/update/destroy
class SessionsController < ApplicationController
  include ApiAuthorizable

  before_action :authenticate_user!
  before_action :set_course
  before_action :set_session, only: [:edit, :update, :destroy]
  before_action :authorize_admin_or_instructor!, only: [:new, :create, :edit, :update, :destroy]

  def new
    @session = @course.sessions.build
  end

  def create
    @session = @course.sessions.build(session_params)

    if @session.save
      redirect_to @course, notice: "Sessão criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @session.update(session_params)
      redirect_to @course, notice: "Sessão atualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @session.destroy
    redirect_to @course, notice: "Sessão removida com sucesso."
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_session
    @session = @course.sessions.find(params[:id])
  end

  def session_params
    params.require(:session).permit(:name, :position)
  end
end
