# frozen_string_literal: true

# Login da API: recebe email/senha e retorna JWT.
# Usa o modelo User (Devise) apenas para validar senha; não cria sessão.
# O tenant vem do subdomínio (set_tenant no ApplicationController).
class Api::V1::Auth::SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  # POST /api/v1/auth/login
  def create
    tenant = ActsAsTenant.current_tenant
    user = User.find_by(email: login_params[:email], tenant_id: tenant.id)

    unless user&.valid_password?(login_params[:password])
      render json: { error: "E-mail ou senha inválidos" }, status: :unauthorized
      return
    end

    token = JwtService.encode(user: user)
    render json: {
      token: token,
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
        tenant_id: user.tenant_id
      }
    }, status: :ok
  end

  private

  def login_params
    params.require(:auth).permit(:email, :password)
  end
end
