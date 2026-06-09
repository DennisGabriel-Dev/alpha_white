# frozen_string_literal: true

# Dados de demonstração idempotentes: contas fixas + conteúdo gerado com Faker.
# Rode: bin/rails db:seed

require "faker"

Faker::Config.locale = "pt-br"
Faker::UniqueGenerator.clear

puts "🌱 Iniciando seeds..."

SEED_PASSWORD = "senha123"

# Vídeos públicos curtos (placeholders estáveis para o player)
DEMO_VIDEO_URLS = [
  "https://www.youtube.com/watch?v=jNQXAC9IVRw",
  "https://www.youtube.com/watch?v=aqz-KE-bpKQ",
  "https://www.youtube.com/watch?v=9bZkp7q19f0"
].freeze

TENANTS_DATA = [
  { name: "Cursinho Objetivo", subdomain: "objetivo", theme: "default", primary_color: "#3C0094",
    tagline: "Sua aprovação no ENEM começa aqui", feature_flags: {} },
  { name: "Cursinho Poliedro", subdomain: "poliedro", theme: "aurora", primary_color: "#4F46E5",
    tagline: "Excelência em vestibulares", feature_flags: {} },
  { name: "Cursinho Anglo", subdomain: "anglo", theme: "merma", primary_color: "#0D9488",
    tagline: "Estude no seu ritmo", feature_flags: { "csv_export" => false } }
].freeze

# Catálogo ENEM por tenant: mesmas áreas (LC, CH, CN, MT), nomes e descrições próprios de cada cursinho.
COURSES_BY_TENANT = {
  "objetivo" => [
    {
      name: "Linguagens e Códigos — Objetivo",
      area: "LC",
      description: "Interpretação de textos, literatura, gramática e língua estrangeira no padrão ENEM."
    },
    {
      name: "Humanas Integradas — Objetivo",
      area: "CH",
      description: "História, geografia, filosofia e sociologia com análise de documentos e contextualização."
    },
    {
      name: "Natureza em Foco — Objetivo",
      area: "CN",
      description: "Física, química e biologia integradas a saúde, meio ambiente e tecnologia."
    },
    {
      name: "Matemática para o ENEM — Objetivo",
      area: "MT",
      description: "Álgebra, geometria, estatística e raciocínio lógico em situações-problema do exame."
    },
    {
      name: "Extensivo Anual ENEM",
      area: nil,
      description: "Preparação completa com as quatro áreas, redação e estratégias de prova ao longo do ano."
    },
    {
      name: "Simulados Oficiais INEP",
      area: nil,
      description: "Provas integradas no formato ENEM, com correção e desempenho por área de conhecimento."
    }
  ],
  "poliedro" => [
    {
      name: "Poliedro LC: Comunicação e Textos",
      area: "LC",
      description: "Leitura, interpretação e produção textual para a área de Linguagens do ENEM."
    },
    {
      name: "Poliedro CH: Mundo e Sociedade",
      area: "CH",
      description: "História, geografia e ciências sociais com leitura crítica de mapas, gráficos e documentos."
    },
    {
      name: "Poliedro CN: Ciências Aplicadas",
      area: "CN",
      description: "Física, química e biologia em problemas interdisciplinares típicos da prova."
    },
    {
      name: "Poliedro MT: Raciocínio Matemático",
      area: "MT",
      description: "Matemática e suas tecnologias com resolução orientada e simulados por tema."
    },
    {
      name: "Semi-extensivo Poliedro ENEM",
      area: nil,
      description: "Revisão intensiva das quatro áreas em seis meses, com foco em desempenho no exame."
    },
    {
      name: "Banco de Simulados Poliedro",
      area: nil,
      description: "Simulados cronometrados com relatório de acertos por área LC, CH, CN e MT."
    }
  ],
  "anglo" => [
    {
      name: "Anglo — Linguagens ENEM",
      area: "LC",
      description: "Domine interpretação de textos, gêneros discursivos e competências de leitura do ENEM."
    },
    {
      name: "Anglo — Ciências Humanas",
      area: "CH",
      description: "História, geografia, filosofia e sociologia com questões comentadas e mapas mentais."
    },
    {
      name: "Anglo — Ciências da Natureza",
      area: "CN",
      description: "Conteúdos de física, química e biologia organizados por habilidades do exame."
    },
    {
      name: "Anglo — Matemática",
      area: "MT",
      description: "Funções, geometria, estatística e análise de gráficos com prática diária."
    },
    {
      name: "ENEM Master Anglo",
      area: nil,
      description: "Trilha completa do ENEM com as quatro áreas, redação e gestão de tempo em prova."
    },
    {
      name: "Simulados Comentados Anglo",
      area: nil,
      description: "Simulados no formato oficial com feedback por questão e evolução por área."
    }
  ]
}.freeze

USERS_BY_TENANT = {
  "objetivo" => [
    { email: "super@objetivo.demo", role: :super_admin },
    { email: "admin@objetivo.demo", role: :tenant_admin },
    { email: "instrutor@objetivo.demo", role: :instructor },
    { email: "aluno1@objetivo.demo", role: :student },
    { email: "aluno2@objetivo.demo", role: :student }
  ],
  "poliedro" => [
    { email: "super@poliedro.demo", role: :super_admin },
    { email: "admin@poliedro.demo", role: :tenant_admin },
    { email: "instrutor@poliedro.demo", role: :instructor },
    { email: "aluno1@poliedro.demo", role: :student },
    { email: "aluno2@poliedro.demo", role: :student }
  ],
  "anglo" => [
    { email: "super@anglo.demo", role: :super_admin },
    { email: "admin@anglo.demo", role: :tenant_admin },
    { email: "instrutor@anglo.demo", role: :instructor },
    { email: "aluno1@anglo.demo", role: :student },
    { email: "aluno2@anglo.demo", role: :student }
  ]
}.freeze

module AlphaWhiteSeed
  module_function

  def lorem_description(max_chars: 1000)
    text = Faker::Lorem.paragraph(sentence_count: rand(4..10))
    text = text[0, max_chars] if text.length > max_chars
    text
  end

  ENEM_SESSION_TOPICS = {
    "LC" => [
      "Interpretação de textos",
      "Literatura brasileira",
      "Gramática e linguagem",
      "Língua estrangeira",
      "Artes e cultura digital"
    ],
    "CH" => [
      "História do Brasil",
      "História geral",
      "Geografia física",
      "Geografia humana",
      "Filosofia e sociologia"
    ],
    "CN" => [
      "Física — mecânica",
      "Química orgânica",
      "Biologia celular",
      "Ecologia e meio ambiente",
      "Física moderna"
    ],
    "MT" => [
      "Funções e gráficos",
      "Geometria plana",
      "Estatística e probabilidade",
      "Álgebra e equações",
      "Trigonometria"
    ],
    nil => [
      "Revisão integrada",
      "Simulado oficial",
      "Estratégias de prova",
      "Gestão de tempo",
      "Redação — estrutura e argumentação"
    ]
  }.freeze

  def session_title(area: nil)
    topics = ENEM_SESSION_TOPICS[area] || ENEM_SESSION_TOPICS[nil]
    topics.sample
  end

  def lesson_title(area: nil)
    topics = ENEM_SESSION_TOPICS[area] || ENEM_SESSION_TOPICS[nil]
    [
      "#{topics.sample} — teoria",
      "#{topics.sample} — questões comentadas",
      "Simulado ENEM ##{Faker::Number.between(from: 1, to: 20)}",
      "Revisão: #{topics.sample}"
    ].sample
  end

  def ensure_demo_enem_library
    path = Rails.root.join("db/fixtures/enem_demo_library.json")
    unless File.file?(path)
      Rails.logger.error "Fixture ENEM demo não encontrada: #{path}"
      return
    end

    payload = JSON.parse(File.read(path))
    exam_data = payload.fetch("exam")
    exam = EnemExam.find_or_initialize_by(
      year: exam_data.fetch("year"),
      day: exam_data.fetch("day"),
      booklet_color: exam_data.fetch("booklet_color").to_s.upcase
    )
    exam.metadata = exam.metadata.merge(exam_data["metadata"] || {}).merge("seed" => "enem_demo_library.json")
    exam.save!

    Array(payload["questions"]).each do |q|
      eq = EnemQuestion.find_or_initialize_by(enem_exam: exam, number_in_exam: q.fetch("number_in_exam"))
      eq.assign_attributes(
        area: q.fetch("area"),
        statement: q.fetch("statement"),
        skill: q["skill"],
        correct_letter: q.fetch("correct_letter").to_s.upcase,
        alternatives: q["alternatives"] || []
      )
      eq.save!
    end

    Rails.logger.info "Biblioteca ENEM demo: prova #{exam.year} #{exam.day} #{exam.booklet_color} (#{exam.enem_questions.count} questões)"
  end

  ACHIEVEMENTS_CATALOG = [
    {
      slug: "first_answer",
      name: "Primeira resposta",
      description: "Respondeu sua primeira questão em uma prova.",
      kind: :event,
      threshold: 1
    },
    {
      slug: "first_lesson_done",
      name: "Primeira aula concluída",
      description: "Concluiu sua primeira aula (vídeo e prova, quando houver).",
      kind: :event,
      threshold: 1
    },
    {
      slug: "streak_3",
      name: "Fogo no estudo (3 dias)",
      description: "Estudou por 3 dias seguidos.",
      kind: :streak,
      threshold: 3
    },
    {
      slug: "streak_7",
      name: "Semana de foco (7 dias)",
      description: "Manteve a sequência de estudo por 7 dias.",
      kind: :streak,
      threshold: 7
    },
    {
      slug: "quiz_perfect",
      name: "Prova perfeita",
      description: "Acertou todas as questões de uma prova.",
      kind: :quiz_perfect,
      threshold: 1
    }
  ].freeze

  def ensure_achievements_catalog
    Gamification::AchievementsCatalog.ensure!
    Rails.logger.info "Catálogo de conquistas: #{Achievement.count} badges"
  end

  def ensure_tenant_branding(tenant, attrs)
    updates = {}
    updates[:primary_color] = attrs[:primary_color] if tenant.primary_color != attrs[:primary_color]
    if Tenant.column_names.include?("theme") && tenant.respond_to?(:theme=)
      updates[:theme] = attrs[:theme] if tenant.theme != attrs[:theme]
    end
    updates[:tagline] = attrs[:tagline] if attrs[:tagline].present? && tenant.tagline != attrs[:tagline]
    if attrs[:feature_flags].present? && tenant.respond_to?(:feature_flags=)
      tenant.assign_feature_flags_from_params(attrs[:feature_flags])
      updates[:feature_flags] = tenant.feature_flags
    end
    tenant.update!(updates) if updates.any?
  end

  def populate_course_structure(course, tenant, area: nil)
    return unless course.sessions.empty?

    ActsAsTenant.with_tenant(tenant) do
      rand(2..4).times do |si|
        session = course.sessions.create!(
          name: session_title(area: area),
          position: si
        )

        rand(2..5).times do |li|
          lesson = session.lessons.create!(
            name: lesson_title(area: area),
            description: lorem_description(max_chars: 800),
            position: li,
            video_url: (rand < 0.72 ? DEMO_VIDEO_URLS.sample : nil)
          )

          next if rand > 0.68

          quiz = lesson.create_quiz!(title: "Check-point: #{Faker::Lorem.sentence(word_count: 3).delete_suffix('.')}")

          rand(2..4).times do |qi|
            n_opts = rand(3..4)
            correct = rand(0...n_opts)

            question = quiz.questions.build(
              enunciation: Faker::Lorem.question(word_count: 8),
              position: qi
            )

            n_opts.times do |oi|
              question.question_options.build(
                text: Faker::Lorem.sentence(word_count: rand(2..5)),
                correct: oi == correct,
                position: oi
              )
            end

            question.save!
          end
        end
      end
    end

    puts "    🧱 Estrutura gerada (sessões/aulas/quizzes): #{course.name}"
  end

  def sync_tenant_courses(tenant, course_catalog)
    expected_names = course_catalog.map { |c| c[:name] }

    ActsAsTenant.with_tenant(tenant) do
      course_catalog.each do |course_data|
        course = Course.find_or_create_by!(name: course_data[:name]) do |c|
          c.description = course_data[:description]
          c.active = true
        end
        updates = {}
        updates[:description] = course_data[:description] if course.description != course_data[:description]
        updates[:active] = true unless course.active?
        course.update!(updates) if updates.any?

        puts "    📚 Curso: #{course.name}"
        populate_course_structure(course, tenant, area: course_data[:area])
      end

      Course.where.not(name: expected_names).where(active: true).find_each do |legacy|
        legacy.update!(active: false)
        puts "    ⏸️ Curso legado desativado: #{legacy.name}"
      end
    end
  end

  def ensure_sample_activity(tenant)
    ActsAsTenant.with_tenant(tenant) do
      students = User.student.where(tenant: tenant).order(:id).limit(6).to_a
      return if students.empty?

      lessons = Lesson.joins(session: :course).where(courses: { tenant_id: tenant.id }).order(:id).limit(18).to_a
      return if lessons.empty?

      # Emparelhamento determinístico: re-seed não multiplica registros
      lessons.each_with_index do |lesson, idx|
        student = students[idx % students.size]
        LessonCompletion.find_or_create_by!(lesson: lesson, user: student) do |lc|
          lc.video_watched = lesson.video_url.present? && (lesson.id % 3 != 0)
          lc.quiz_completed = lesson.quiz.present? && (lesson.id % 4 != 0)
        end
      end

      lessons.first(6).each_with_index do |lesson, idx|
        student = students[idx % students.size]
        Feedback.find_or_create_by!(lesson: lesson, user: student) do |f|
          f.rating = [ 4, 5 ].sample
          f.description = "#{Faker::Lorem.sentence} — #{Faker::Movies::StarWars.quote}"
        end
      end
    end

    puts "    📈 Atividade de alunos (completions/feedbacks) em #{tenant.subdomain}"
  end

  def ensure_turma_users(tenant, count: 8)
    ActsAsTenant.with_tenant(tenant) do
      (1..count).each do |n|
        email = format("turma%02d.%s@seed.demo", n, tenant.subdomain)
        user = User.find_or_initialize_by(email: email)
        user.assign_attributes(
          password: SEED_PASSWORD,
          role: :student,
          tenant: tenant
        )
        user.save!
      end
    end
  end
end

AlphaWhiteSeed.ensure_demo_enem_library
AlphaWhiteSeed.ensure_achievements_catalog

# --- Tenants ---
tenants = []
TENANTS_DATA.each do |data|
  attrs = data.except(:name, :subdomain)
  tenant = Tenant.find_or_create_by!(subdomain: data[:subdomain]) do |t|
    t.name = data[:name]
    t.active = true
  end
  tenant.update!(name: data[:name]) if tenant.name != data[:name]
  AlphaWhiteSeed.ensure_tenant_branding(tenant, attrs)
  tenants << tenant
  puts "  ✅ Tenant: #{tenant.name} (#{tenant.subdomain})"
end

# --- Cursos ENEM + árvore de conteúdo ---
tenants.each do |tenant|
  AlphaWhiteSeed.sync_tenant_courses(tenant, COURSES_BY_TENANT.fetch(tenant.subdomain))
end

# --- Usuários (contas de demo + turma numerada) ---
super_tenant = tenants.first
super_user = User.find_or_initialize_by(email: "super@alpha.demo")
ActsAsTenant.with_tenant(super_tenant) do
  super_user.assign_attributes(password: SEED_PASSWORD, role: :super_admin, tenant: super_tenant)
  super_user.save!
end
puts "  ✅ Super admin global: super@alpha.demo"

tenants.each do |tenant|
  list = USERS_BY_TENANT[tenant.subdomain] || []
  ActsAsTenant.with_tenant(tenant) do
    list.each do |data|
      user = User.find_or_initialize_by(email: data[:email])
      user.assign_attributes(password: SEED_PASSWORD, role: data[:role], tenant: tenant)
      user.save!
      puts "  ✅ Usuário #{tenant.subdomain}: #{data[:email]} (#{data[:role]})"
    end
  end
  AlphaWhiteSeed.ensure_turma_users(tenant, count: 8)
  puts "  👥 Turma seed: turma01.#{tenant.subdomain}@seed.demo … turma08.#{tenant.subdomain}@seed.demo"
end

# --- Engajamento de exemplo (não duplica em re-runs graças a find_or_create) ---
tenants.each { |t| AlphaWhiteSeed.ensure_sample_activity(t) }

puts ""
puts "✨ Seeds concluídos!"
puts ""
puts "📊 Resumo:"
puts "  - #{Tenant.count} tenants (cursinhos)"
puts "  - #{Course.count} cursos no total"
puts "  - #{Session.count} sessões"
puts "  - #{Lesson.count} aulas"
puts "  - #{Quiz.count} quizzes / #{Question.count} questões"
puts "  - #{EnemExam.count} edições ENEM (biblioteca global) / #{EnemQuestion.count} questões ENEM"
puts "  - #{User.count} usuários"
puts "  - #{LessonCompletion.count} registros de progresso"
puts "  - #{Feedback.count} feedbacks"
puts ""
puts "🔐 Senha padrão (todas as contas de seed): #{SEED_PASSWORD}"
puts ""
puts "🌐 Acesse os tenants:"
tenants.each do |tenant|
  courses_count = ActsAsTenant.with_tenant(tenant) { Course.count }
  puts "  - #{tenant.name}: http://#{tenant.subdomain}.lvh.me:3000 (#{courses_count} cursos)"
end
