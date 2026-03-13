module ApiJwtAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_api_request!
  end

  private

  def authenticate_api_request!
    token = bearer_token
    unless token
      render json: { error: "Token ausente" }, status: :unauthorized
      return
    end

    payload = JwtService.decode(token)
    unless payload
      render json: { error: "Token inválido ou expirado" }, status: :unauthorized
      return
    end

    user = User.find_by(id: payload[:sub])
    unless user
      render json: { error: "Usuário não encontrado" }, status: :unauthorized
      return
    end

    current_tenant = ActsAsTenant.current_tenant
    if current_tenant && user.tenant_id != current_tenant.id
      render json: { error: "Token não autorizado!" }, status: :forbidden
      return
    end

    @current_user = user
  end

  def current_user
    @current_user
  end

  def bearer_token
    auth = request.authorization
    return nil unless auth&.start_with?("Bearer ")

    auth.sub("Bearer ", "")
  end
end
