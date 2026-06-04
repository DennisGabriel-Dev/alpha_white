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

  # Retorna a URL do logo do tenant (upload via Active Storage)
  def tenant_logo_url
    return unless current_tenant&.logo&.attached?

    url_for(current_tenant.logo)
  end

  def tenant_logo_attached?
    current_tenant&.logo&.attached?
  end

  def tenant_favicon_url
    if current_tenant&.favicon&.attached?
      url_for(current_tenant.favicon)
    else
      "/icon.png"
    end
  end

  def tenant_tagline
    current_tenant&.tagline.presence || Tenant::DEFAULT_TAGLINE
  end

  def tenant_meta_description
    current_tenant&.meta_description.presence || Tenant::DEFAULT_META_DESCRIPTION
  end

  def tenant_feature?(key)
    current_tenant&.feature_enabled?(key) == true || current_user&.super_admin?
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

  def theme_page_container_class(max_width: "4xl")
    if themed_layout?
      "max-w-#{max_width} mx-auto px-5 py-6"
    else
      "container mx-auto px-4 py-8 max-w-#{max_width}"
    end
  end

  def theme_card_class
    if themed_layout?
      "rounded-2xl border border-gray-100 bg-white shadow-sm"
    else
      "card"
    end
  end

  def theme_panel_class
    themed_layout? ? "rounded-2xl border border-gray-100 bg-white p-4 shadow-sm" : "rounded-xl border border-gray-200 bg-white p-4 shadow-sm"
  end

  def theme_btn_primary_class(extra: "")
    base = case current_tenant&.theme
           when "aurora" then "aurora-btn-primary inline-flex items-center justify-center rounded-xl text-sm font-semibold transition-colors"
           when "merma" then "merma-btn-primary inline-flex items-center justify-center rounded-xl text-sm font-semibold transition-colors"
           else "btn-primary inline-flex items-center justify-center"
           end
    [base, extra].join(" ").strip
  end

  def theme_btn_secondary_class(extra: "")
    ["inline-flex items-center justify-center rounded-xl text-sm font-medium border border-gray-200 text-gray-600 hover:bg-gray-50 transition-colors", extra].join(" ").strip
  end

  def theme_nav_pill_class(active:)
    base = "px-3 py-1.5 rounded-lg border text-sm font-medium transition-colors"
    if active
      if themed_layout?
        "#{base} border-[var(--color-primary)] bg-[var(--color-primary)]/10 text-[var(--color-primary)]"
      else
        "#{base} border-primary bg-primary/10 text-primary"
      end
    else
      "#{base} border-gray-200 text-gray-700 hover:bg-gray-50"
    end
  end

  def theme_table_wrap_class
    themed_layout? ? "overflow-x-auto rounded-2xl border border-gray-100 bg-white" : "overflow-x-auto rounded-xl border border-gray-200"
  end
end
