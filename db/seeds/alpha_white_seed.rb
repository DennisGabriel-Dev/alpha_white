# frozen_string_literal: true

require "faker"

module AlphaWhiteSeed
  DEMO_VIDEO_URLS = [
    "https://www.youtube.com/watch?v=jNQXAC9IVRw",
    "https://www.youtube.com/watch?v=aqz-KE-bpKQ",
    "https://www.youtube.com/watch?v=9bZkp7q19f0"
  ].freeze

  module_function

  def configure_faker!
    Faker::Config.locale = "pt-br"
    Faker::UniqueGenerator.clear
  end

  def lorem_description(max_chars: 1000)
    text = Faker::Lorem.paragraph(sentence_count: rand(4..10))
    text = text[0, max_chars] if text.length > max_chars
    text
  end

  def session_title
    topics = [
      Faker::Science.science,
      Faker::Educator.subject,
      Faker::Book.genre,
      "Revisão #{Faker::Number.between(from: 1, to: 12)}ª semana"
    ]
    topics.sample
  end

  def lesson_title
    [
      "Fundamentos: #{Faker::Lorem.sentence(word_count: 4).delete_suffix('.')}",
      "Prática guiada — #{Faker::Educator.course_name}",
      "Dúvidas frequentes: #{Faker::Lorem.sentence(word_count: 3).delete_suffix('.')}",
      "Simulado comentado ##{Faker::Number.between(from: 1, to: 20)}"
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

  def populate_course_structure(course, tenant)
    return unless course.sessions.empty?

    ActsAsTenant.with_tenant(tenant) do
      rand(2..4).times do |si|
        session = course.sessions.create!(
          name: session_title,
          position: si
        )

        rand(2..5).times do |li|
          lesson = session.lessons.create!(
            name: lesson_title,
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

  def ensure_extra_courses(tenant)
    extras = [
      "Trilha de revisão — #{tenant.subdomain}",
      "Simulados comentados — #{tenant.subdomain}"
    ]

    ActsAsTenant.with_tenant(tenant) do
      extras.each do |name|
        course = Course.find_or_create_by!(name: name) do |c|
          c.description = lorem_description
          c.active = true
        end
        populate_course_structure(course, tenant)
      end
    end
  end

  def ensure_sample_activity(tenant)
    ActsAsTenant.with_tenant(tenant) do
      students = User.student.where(tenant: tenant).order(:id).limit(6).to_a
      return if students.empty?

      lessons = Lesson.joins(session: :course).where(courses: { tenant_id: tenant.id }).order(:id).limit(18).to_a
      return if lessons.empty?

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

  def ensure_turma_users(tenant, password:, count: 8)
    ActsAsTenant.with_tenant(tenant) do
      (1..count).each do |n|
        email = format("turma%02d.%s@seed.demo", n, tenant.subdomain)
        user = User.find_or_initialize_by(email: email)
        user.assign_attributes(
          password: password,
          role: :student,
          tenant: tenant
        )
        user.save!
      end
    end
  end

  def populate_tenant!(tenant, password:, courses:, users:, extra_courses: true, sample_activity: true, turma_count: 8)
    ActsAsTenant.with_tenant(tenant) do
      courses.each do |course_data|
        course = Course.find_or_create_by!(name: course_data[:name]) do |c|
          c.description = course_data[:description]
          c.active = true
        end
        if course.description != course_data[:description]
          course.update!(description: course_data[:description])
        end
        puts "    📚 Curso: #{course.name}"
        populate_course_structure(course, tenant)
      end
    end

    ensure_extra_courses(tenant) if extra_courses

    ActsAsTenant.with_tenant(tenant) do
      users.each do |data|
        user = User.find_or_initialize_by(email: data[:email])
        user.assign_attributes(password: password, role: data[:role], tenant: tenant)
        user.save!
        puts "  ✅ Usuário #{tenant.subdomain}: #{data[:email]} (#{data[:role]})"
      end
    end

    ensure_turma_users(tenant, password: password, count: turma_count)
    puts "  👥 Turma seed: turma01.#{tenant.subdomain}@seed.demo … turma#{format('%02d', turma_count)}.#{tenant.subdomain}@seed.demo"
    ensure_sample_activity(tenant) if sample_activity
  end
end
