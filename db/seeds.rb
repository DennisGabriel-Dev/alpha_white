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

puts ""
puts "✨ Seeds concluídos!"
puts ""
puts "📊 Resumo:"
puts "  - #{Tenant.count} tenants (cursinhos)"
puts "  - #{Course.count} cursos no total"
puts ""
puts "🌐 Acesse os tenants:"
tenants.each do |tenant|
  courses_count = ActsAsTenant.with_tenant(tenant) { Course.count }
  puts "  - #{tenant.name}: http://#{tenant.subdomain}.localhost:3000 (#{courses_count} cursos)"
end
