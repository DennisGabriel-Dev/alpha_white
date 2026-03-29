# Alpha White - Comandos Docker (uso em desenvolvimento/apresentação)
# Pré-requisito: Docker e Docker Compose instalados

.PHONY: help start start_background stop setup db_prepare db_seed db_create console logs update_lock

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

# Copia Gemfile.lock atualizado do container para o host (útil se você roda só no Docker e adicionou uma gem)
update_lock:
	docker compose run --rm app cat Gemfile.lock > Gemfile.lock
	@echo "Gemfile.lock atualizado. Pode commitar se quiser versionar."
