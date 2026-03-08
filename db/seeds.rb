# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Iniciando seeds..."

# Criar Tenants (Cursinhos)
tenants_data = [
  { name: "Cursinho Objetivo", subdomain: "objetivo" },
  { name: "Cursinho Poliedro", subdomain: "poliedro" },
  { name: "Cursinho Anglo", subdomain: "anglo" }
]

tenants = []
tenants_data.each do |data|
  tenant = Tenant.find_or_create_by!(subdomain: data[:subdomain]) do |t|
    t.name = data[:name]
    t.active = true
  end
  tenants << tenant
  puts "  ✅ Tenant criado: #{tenant.name} (#{tenant.subdomain})"
end

# Criar Cursos para cada Tenant
courses_by_tenant = {
  "objetivo" => [
    { name: "Medicina Intensivo", description: "Preparatório intensivo para Medicina com foco em questões ENEM e vestibulares concorridos." },
    { name: "Engenharia Premium", description: "Curso completo para aprovação em Engenharia nas melhores universidades." },
    { name: "Extensivo Anual", description: "Curso completo de 1 ano com todas as matérias do ENEM." }
  ],
  "poliedro" => [
    { name: "ITA/IME Elite", description: "Preparação exclusiva para ITA e IME com professores especializados." },
    { name: "Medicina USP", description: "Foco total na aprovação em Medicina nas universidades paulistas." },
    { name: "Semi-extensivo", description: "Curso de 6 meses para revisão e aprofundamento." }
  ],
  "anglo" => [
    { name: "ENEM Master", description: "Curso completo focado exclusivamente no ENEM." },
    { name: "Unicamp/Unesp", description: "Preparação específica para vestibulares Unicamp e Unesp." },
    { name: "Módulo Online", description: "Todas as aulas disponíveis online com suporte ao vivo." }
  ]
}

tenants.each do |tenant|
  ActsAsTenant.with_tenant(tenant) do
    courses = courses_by_tenant[tenant.subdomain] || []

    courses.each do |course_data|
      course = Course.find_or_create_by!(name: course_data[:name]) do |c|
        c.description = course_data[:description]
        c.active = true
      end
      puts "    📚 Curso criado para #{tenant.subdomain}: #{course.name}"
    end
  end
end

# Senha padrão para todos os usuários de seed (desenvolvimento)
SEED_PASSWORD = "senha123"

# Usuários por tenant: admin, instrutor e estudantes (email único por tenant no formato tenant_email)
users_by_tenant = {
  "objetivo" => [
    { email: "admin@objetivo.demo", role: :tenant_admin },
    { email: "instrutor@objetivo.demo", role: :instructor },
    { email: "aluno1@objetivo.demo", role: :student },
    { email: "aluno2@objetivo.demo", role: :student }
  ],
  "poliedro" => [
    { email: "admin@poliedro.demo", role: :tenant_admin },
    { email: "instrutor@poliedro.demo", role: :instructor },
    { email: "aluno1@poliedro.demo", role: :student },
    { email: "aluno2@poliedro.demo", role: :student }
  ],
  "anglo" => [
    { email: "admin@anglo.demo", role: :tenant_admin },
    { email: "instrutor@anglo.demo", role: :instructor },
    { email: "aluno1@anglo.demo", role: :student },
    { email: "aluno2@anglo.demo", role: :student }
  ]
}

# Super admin (vinculado ao primeiro tenant)
super_tenant = tenants.first
super_user = User.find_or_initialize_by(email: "super@alpha.demo")
super_user.assign_attributes(password: SEED_PASSWORD, role: :super_admin, tenant: super_tenant)
super_user.save!
puts "  ✅ Super admin: super@alpha.demo"

tenants.each do |tenant|
  list = users_by_tenant[tenant.subdomain] || []
  list.each do |data|
    user = User.find_or_initialize_by(email: data[:email])
    user.assign_attributes(password: SEED_PASSWORD, role: data[:role], tenant: tenant)
    user.save!
    puts "  ✅ Usuário #{tenant.subdomain}: #{data[:email]} (#{data[:role]})"
  end
end

puts ""
puts "✨ Seeds concluídos!"
puts ""
puts "📊 Resumo:"
puts "  - #{Tenant.count} tenants (cursinhos)"
puts "  - #{Course.count} cursos no total"
puts "  - #{User.count} usuários"
puts ""
puts "🔐 Senha padrão dos usuários de seed: #{SEED_PASSWORD}"
puts ""
puts "🌐 Acesse os tenants:"
tenants.each do |tenant|
  courses_count = ActsAsTenant.with_tenant(tenant) { Course.count }
  puts "  - #{tenant.name}: http://#{tenant.subdomain}.lvh.me:3000 (#{courses_count} cursos)"
end
