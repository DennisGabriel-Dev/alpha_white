# frozen_string_literal: true

# Verifica se o usuário atual é Admin ou Instrutor do tenant.
# Usado para permitir create/update/destroy de sessões, aulas, provas etc.
module ApiAuthorizable
  extend ActiveSupport::Concern

  private

  def authorize_admin_or_instructor!
    return if current_user&.super_admin? || current_user&.tenant_admin? || current_user&.instructor?

    render json: { error: "Acesso negado. Apenas Admin ou Instrutor podem realizar esta ação." },
           status: :forbidden
  end
end
