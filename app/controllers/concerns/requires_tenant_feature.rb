module RequiresTenantFeature
  extend ActiveSupport::Concern

  private

  def require_tenant_feature!(feature)
    return if current_tenant&.feature_enabled?(feature)

    redirect_to root_path, alert: tenant_feature_disabled_alert(feature)
  end

  def tenant_feature_disabled_alert(feature)
    labels = {
      "gamification" => "Gamificação",
      "reports" => "Relatórios",
      "enem_library" => "Biblioteca ENEM",
      "csv_export" => "Exportação CSV"
    }
    "#{labels.fetch(feature.to_s, feature.to_s.humanize)} não está habilitado neste cursinho."
  end
end
