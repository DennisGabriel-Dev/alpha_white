class PagesController < ApplicationController
  def home
    # Buscar cursos em destaque (apenas 6 para a home)
    @featured_courses = Course.where(active: true).limit(6)

    # Dados para seção de benefícios
    @benefits = [
      {
        icon: :book_open,
        title: "Conteúdo completo do ENEM",
        description: "Todo o conteúdo que você precisa para arrasar no ENEM, organizado por disciplinas e temas."
      },
      {
        icon: :chart_bar,
        title: "Acompanhe sua evolução",
        description: "Veja seu progresso em tempo real e identifique pontos de melhoria com relatórios detalhados."
      },
      {
        icon: :academic_cap,
        title: "Simulados realistas",
        description: "Pratique com simulados no formato do ENEM e se prepare de verdade para o dia da prova."
      }
    ]

    @tracks = build_enem_tracks
  end

  private

  def build_enem_tracks
    Course.where(active: true).order(:id).map do |course|
      track_presentation_for(course).merge(
        name: course.name,
        description: course.description,
        course: course
      )
    end
  end

  def track_presentation_for(course)
    label = course.name.downcase

    if label.include?("simulado") || label.include?("banco de simulados")
      { hours: 24, level: "Avançado", courses_count: 1 }
    elsif label.match?(/extensivo|semi-extensivo|master|completo|anual/)
      { hours: 120, level: "Todos os níveis", courses_count: 4 }
    elsif label.match?(/matemática|matematico|raciocínio matemático|: mt/)
      { hours: 40, level: "Intermediário", courses_count: 1 }
    else
      { hours: 48, level: "Intermediário", courses_count: 1 }
    end
  end
end
