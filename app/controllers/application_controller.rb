class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  protect_from_forgery with: :null_session

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Configura multi-tenancy
  set_current_tenant_through_filter
  before_action :set_tenant

  private

  def set_tenant
    # Extrai o subdomínio da requisição
    subdomain = request.subdomain

    # Se não houver subdomínio ou for 'www', redireciona ou mostra erro
    if subdomain.blank? || subdomain == "www"
      render plain: "Acesso negado: Subdomínio não encontrado", status: :not_found
      return
    end

    # Busca o tenant pelo subdomínio
    tenant = Tenant.find_by(subdomain: subdomain, active: true)

    if tenant
      set_current_tenant(tenant)
    else
      render plain: "Cursinho não encontrado: #{subdomain}", status: :not_found
    end
  end
end
