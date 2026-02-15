module ApplicationHelper
  include IconHelper
  # Retorna o tenant atual
  def current_tenant
    ActsAsTenant.current_tenant
  end

  # Retorna a cor primária do tenant atual ou cor padrão
  def tenant_primary_color
    current_tenant&.primary_color || "#3C0094"
  end

  # Retorna o nome do tenant atual ou nome padrão
  def tenant_name
    current_tenant&.name || "Alpha White"
  end

  # Retorna a URL do logo do tenant ou logo padrão
  def tenant_logo_url
    current_tenant&.logo_url || nil
  end

  # Helper para verificar se há tenant ativo
  def tenant_present?
    current_tenant.present?
  end

  def admin_or_instructor?
    return false unless user_signed_in?

    current_user.super_admin? || current_user.tenant_admin? || current_user.instructor?
  end

  def student?
    return false unless user_signed_in?

    current_user.student?
  end

  def super_admin?
    return false unless user_signed_in?

    current_user.super_admin?
  end

  def instructor?
    return false unless user_signed_in?

    current_user.instructor?
  end
end
