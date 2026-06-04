# frozen_string_literal: true

class StaffUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_tenant_admin!

  def index
    @instructors = User.where(tenant: current_tenant, role: :instructor).order(:email)
  end

  def new
    @instructor = User.new(role: :instructor)
  end

  def create
    @instructor = User.new(instructor_params)
    @instructor.tenant = current_tenant
    @instructor.role = :instructor

    if @instructor.save
      redirect_to staff_users_path, notice: "Instrutor #{@instructor.email} criado com sucesso."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def require_tenant_admin!
    return if tenant_admin?

    redirect_to root_path, alert: "Acesso negado. Apenas administradores do cursinho podem gerenciar instrutores."
  end

  def instructor_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
