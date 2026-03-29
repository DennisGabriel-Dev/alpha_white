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

  # Verdadeiro quando o tenant usa um layout próprio (não o application padrão)
  def themed_layout?
    current_tenant&.theme.present? && current_tenant.theme != "default"
  end

  # Cores cíclicas para ícones de cursos no tema Merma
  MERMA_COURSE_PALETTE = [
    { bg: "#EEF2FF", text: "#4338CA" },
    { bg: "#FEF3C7", text: "#B45309" },
    { bg: "#D1FAE5", text: "#047857" },
    { bg: "#FCE7F3", text: "#BE185D" },
    { bg: "#CCFBF1", text: "#0F766E" },
    { bg: "#FEE2E2", text: "#B91C1C" },
    { bg: "#E0E7FF", text: "#4F46E5" },
    { bg: "#FEF9C3", text: "#A16207" }
  ].freeze

  def merma_course_color(index)
    MERMA_COURSE_PALETTE[index % MERMA_COURSE_PALETTE.size]
  end

  # Cursos para a sidebar de navegação do tema Merma
  def merma_nav_courses
    @merma_nav_courses ||= Course.active.limit(15)
  end
end
