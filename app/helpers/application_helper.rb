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
end
