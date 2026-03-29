class ApplicationController < ActionController::Base
  include PermissionHelper

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  protect_from_forgery with: :null_session

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  layout :resolve_layout

  # Configura multi-tenancy
  set_current_tenant_through_filter
  before_action :set_tenant
  before_action :set_locale
  before_action :set_active_storage_url_options

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

  def require_admin_or_instructor!
    return if admin_or_instructor?

    redirect_to root_path, alert: "Acesso negado. Apenas administradores ou instrutores podem realizar esta ação."
  end

  def resolve_layout
    theme = current_tenant&.theme
    theme.present? && theme != "default" ? theme : "application"
  end

  def set_locale
    I18n.locale = "pt-br"
  end

  def set_active_storage_url_options
    ActiveStorage::Current.url_options = {
      protocol: request.protocol,
      host: request.host,
      port: request.optional_port
    }
  end
end
