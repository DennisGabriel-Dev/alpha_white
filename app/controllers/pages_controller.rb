class PagesController < ApplicationController
  def home
    # Buscar cursos em destaque (apenas 6 para a home)
    @featured_courses = Course.where(active: true).limit(6)

    # Dados para seção de benefícios
    @benefits = [
      {
        icon: "📚",
        title: "Conteúdo completo do ENEM",
        description: "Todo o conteúdo que você precisa para arrasar no ENEM, organizado por disciplinas e temas."
      },
      {
        icon: "📊",
        title: "Acompanhe sua evolução",
        description: "Veja seu progresso em tempo real e identifique pontos de melhoria com relatórios detalhados."
      },
      {
        icon: "🎯",
        title: "Simulados realistas",
        description: "Pratique com simulados no formato do ENEM e se prepare de verdade para o dia da prova."
      }
    ]

    # Mock de trilhas (será implementado depois)
    @tracks = [
      {
        name: "ENEM Completo",
        description: "Trilha completa com todas as disciplinas do ENEM",
        courses_count: 12,
        hours: 80,
        level: "Iniciante"
      },
      {
        name: "Matemática Intensiva",
        description: "Domine matemática e suas tecnologias",
        courses_count: 8,
        hours: 40,
        level: "Intermediário"
      },
      {
        name: "Redação Nota 1000",
        description: "Aprenda a fazer redações perfeitas",
        courses_count: 4,
        hours: 20,
        level: "Todos os níveis"
      }
    ]
  end
end
