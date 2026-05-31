# frozen_string_literal: true

# Cria e popula o cursinho Alpha White (mesmo conteúdo do db:seed, só para este tenant).
#
# Produção (no servidor):
#   docker compose exec app bin/rails console -e production
#   load Rails.root.join("db/console/create_alphawhite_tenant.rb")
#
# Senha customizada:
#   export ALPHA_WHITE_ADMIN_PASSWORD='sua-senha'
#   docker compose exec -e ALPHA_WHITE_ADMIN_PASSWORD app bin/rails console -e production

require Rails.root.join("db/seeds/alpha_white_seed")

SUBDOMAIN     = "alphawhite"
NAME          = "Alpha White"
PRIMARY_COLOR = "#F97316" # laranja (fundo branco vem do tema merma)
THEME         = "merma"
BASE_HOST     = "alphawhite.ddns.net" # ajuste se o domínio for outro
SEED_PASSWORD = ENV.fetch("ALPHA_WHITE_ADMIN_PASSWORD", "AlphaWhite123!")

COURSES = [
  { name: "ENEM Master", description: "Curso completo focado exclusivamente no ENEM." },
  { name: "Medicina Intensivo", description: "Preparatório intensivo para Medicina com foco em questões ENEM e vestibulares concorridos." },
  { name: "Extensivo Anual", description: "Curso completo de 1 ano com todas as matérias do ENEM." }
].freeze

USERS = [
  { email: "super@alphawhite.demo", role: :super_admin },
  { email: "admin@alphawhite.demo", role: :tenant_admin },
  { email: "instrutor@alphawhite.demo", role: :instructor },
  { email: "aluno1@alphawhite.demo", role: :student },
  { email: "aluno2@alphawhite.demo", role: :student }
].freeze

puts "🌱 Populando tenant Alpha White..."

AlphaWhiteSeed.configure_faker!
AlphaWhiteSeed.ensure_demo_enem_library
AlphaWhiteSeed.ensure_achievements_catalog

tenant = Tenant.find_or_initialize_by(subdomain: SUBDOMAIN)
tenant.assign_attributes(
  name: NAME,
  active: true,
  primary_color: PRIMARY_COLOR,
  theme: THEME
)
tenant.save!

puts "✅ Tenant: #{tenant.name} (#{tenant.subdomain})"
puts "   Cor primária: #{tenant.primary_color} | Tema: #{tenant.theme}"
puts "   URL: https://#{tenant.subdomain}.#{BASE_HOST}"

AlphaWhiteSeed.populate_tenant!(
  tenant,
  password: SEED_PASSWORD,
  courses: COURSES,
  users: USERS
)

courses_count = ActsAsTenant.with_tenant(tenant) { Course.count }
users_count = ActsAsTenant.with_tenant(tenant) { User.count }

puts ""
puts "✨ Alpha White pronto!"
puts "  - #{courses_count} cursos"
puts "  - #{users_count} usuários (inclui turma01…turma08)"
puts "🔐 Senha de todas as contas: #{SEED_PASSWORD}"
puts "🌐 https://#{tenant.subdomain}.#{BASE_HOST}"
