# Alpha White - Comandos Docker (uso em desenvolvimento/apresentação)
# Pré-requisito: Docker e Docker Compose instalados

.PHONY: help start start_background stop setup db_prepare db_test_prepare db_seed db_create console logs update_lock test test-coverage \
        sonar-up sonar-down sonar-logs sonar-scan sonar-check-sysctl sonar-report

help:
	@echo "Alpha White - Comandos disponíveis:"
	@echo "  make setup          - Primeira vez: build, preparar banco e seed"
	@echo "  make start          - Sobe app e banco (foreground)"
	@echo "  make start_background - Sobe app e banco em background"
	@echo "  make stop           - Para os containers"
	@echo "  make db_prepare     - Cria/migra banco (db:prepare)"
	@echo "  make db_seed        - Roda seeds"
	@echo "  make db_create      - Apenas db:create"
	@echo "  make console        - Abre Rails console no container"
	@echo "  make logs           - Mostra logs do app"
	@echo "  make update_lock    - Copia Gemfile.lock do container para o host (após add gem)"
	@echo "  make test           - Roda testes (RSpec no banco alpha_white_test)"
	@echo "  make test-coverage  - RSpec + SimpleCov (coverage/coverage.xml para Sonar)"
	@echo "  make db_test_prepare - Cria/migra o banco de teste (primeira vez no Docker)"
	@echo ""
	@echo "SonarQube (stack separada — não usa o Postgres da app):"
	@echo "  make sonar-check-sysctl - Avisa se vm.max_map_count está ok (Linux)"
	@echo "  make sonar-up           - Sobe SonarQube + Postgres dedicado (porta 9000)"
	@echo "  make sonar-down         - Para a stack SonarQube"
	@echo "  make sonar-logs         - Logs do SonarQube"
	@echo "  make sonar-scan         - Analisa o código (exige SONAR_TOKEN no ambiente)"
	@echo "  make sonar-report       - test-coverage + sonar-scan (cobertura no painel)"

setup: start_background
	@echo "Aguardando containers (primeira vez pode demorar no build)..."
	@sleep 12
	$(MAKE) db_prepare
	$(MAKE) db_seed
	@echo "Pronto. Acesse http://localhost:3000"

start:
	docker compose up --build

start_background:
	docker compose up -d --build

stop:
	docker compose down

db_prepare:
	docker compose exec app bin/rails db:prepare

db_test_prepare:
	docker compose exec -e RAILS_ENV=test -e DATABASE_URL=postgresql://postgres@db:5432/alpha_white_test app bin/rails db:prepare

db_seed:
	docker compose exec app bin/rails db:seed

db_create:
	docker compose exec app bin/rails db:create

console:
	docker compose exec app bin/rails console

logs:
	docker compose logs -f app

migrate:
	docker compose exec app bin/rails db:migrate

# RAILS_ENV=test + DATABASE_URL do banco de teste: no Docker, DATABASE_URL aponta para
# alpha_white_development; se não sobrescrever, o purge do schema de teste tenta o DB errado
# e falha com PG::ObjectInUse. bundle exec rspec evita o rake spec:prepare (tailwind) em todo run.
test:
	docker compose exec -e RAILS_ENV=test -e DATABASE_URL=postgresql://postgres@db:5432/alpha_white_test app bundle exec rspec

# Monta o projeto no host e gera coverage/sonar-coverage.xml para o Sonar
test-coverage:
	docker compose run --rm \
	  -v "$(CURDIR):/app" -w /app \
	  -e RAILS_ENV=test \
	  -e DATABASE_URL=postgresql://postgres@db:5432/alpha_white_test \
	  -e COVERAGE=true \
	  app sh -c "bundle check || bundle install && bundle exec rspec"
	@test -f coverage/coverage.xml || (echo "ERRO: coverage/coverage.xml não gerado" && exit 1)
	@docker compose run --rm -v "$(CURDIR):/app" -w /app app \
	  ruby script/coverage_for_sonar.rb
	@test -f coverage/sonar-coverage.xml
	@echo "Cobertura: coverage/index.html + coverage/sonar-coverage.xml (Sonar)"

coverage-for-sonar:
	@test -f coverage/coverage.xml || (echo "ERRO: rode make test-coverage antes" && exit 1)
	@docker compose run --rm -v "$(CURDIR):/app" -w /app app ruby script/coverage_for_sonar.rb

# Copia Gemfile.lock atualizado do container para o host (útil se você roda só no Docker e adicionou uma gem)
update_lock:
	docker compose run --rm app cat Gemfile.lock > Gemfile.lock
	@echo "Gemfile.lock atualizado. Pode commitar se quiser versionar."

# --- SonarQube (docker-compose.sonar.yml) — banco "sonar" isolado do alpha_white ---

sonar-check-sysctl:
	@sysctl vm.max_map_count 2>/dev/null | grep -q '262144' && \
		echo "vm.max_map_count OK." || \
		echo "AVISO (Linux): rode sudo sysctl -w vm.max_map_count=262144 antes do sonar-up"

sonar-up: sonar-check-sysctl
	docker compose -f docker-compose.sonar.yml up -d
	@echo "Aguarde ~1–2 min. UI: http://localhost:9000 (admin/admin na 1ª vez)"
	@echo "Gere token: My Account > Security > Generate Tokens"
	@echo "Depois: export SONAR_TOKEN=... && make sonar-scan"

sonar-down:
	docker compose -f docker-compose.sonar.yml down

sonar-logs:
	docker compose -f docker-compose.sonar.yml logs -f sonarqube

sonar-scan:
	@test -n "$$SONAR_TOKEN" || (echo "Defina SONAR_TOKEN (token do SonarQube)" && exit 1)
	@test -f coverage/sonar-coverage.xml || (echo "ERRO: rode make test-coverage antes" && exit 1)
	docker compose -f docker-compose.sonar.yml --profile scan run --rm sonar-scanner

sonar-report: test-coverage sonar-scan

# Swagger UI em public/swagger-ui (evita CDN unpkg no api-docs)
vendor-swagger-ui:
	@mkdir -p public/swagger-ui
	curl -fsSL -o public/swagger-ui/swagger-ui.css "https://unpkg.com/swagger-ui-dist@5.9.0/swagger-ui.css"
	curl -fsSL -o public/swagger-ui/swagger-ui-bundle.js "https://unpkg.com/swagger-ui-dist@5.9.0/swagger-ui-bundle.js"
	curl -fsSL -o public/swagger-ui/swagger-ui-standalone-preset.js "https://unpkg.com/swagger-ui-dist@5.9.0/swagger-ui-standalone-preset.js"
	@echo "Swagger UI em public/swagger-ui/"