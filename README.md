# Alpha White - Plataforma Whitelabel para Cursinhos Preparatórios

Aplicação Rails 8 com arquitetura **multi-tenant** usando row-level tenancy. Cada cursinho preparatório é um tenant isolado, com seus próprios dados e acesso via subdomínio.

*Essa aplicação também possui um módulo próprio para API, caso deseje criar a sua própria UI.*

**O projeto roda apenas com Docker.** Não é necessário instalar Ruby nem PostgreSQL na máquina.
---

## 🚀 Como rodar (para o professor / qualquer máquina)

### Pré-requisitos

- **Docker** e **Docker Compose** instalados  
  - [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows/Mac) ou Docker Engine + Compose (Linux)

### Primeira vez
Obs: pode ser necessário instalar o make: ```sudo apt install make```, caso você opte por usar os atalhos introduzidos no makefile
```bash
git clone git@github.com:DennisGabriel-Dev/alpha_white.git
cd alpha_white
touch .env
# Sobe containers, prepara o banco e popula com dados iniciais
make setup
```

O primeiro `make setup` pode demorar alguns minutos (build da imagem). Quando terminar, acesse:

- **App:** http://localhost:3000  
- **Subdomínios (cada subdomnínio pertence a um cursinho):**  
  - http://objetivo.lvh.me:3000  
  - http://poliedro.lvh.me:3000  
  - http://anglo.lvh.me:3000  

Se aparecer erro de banco na primeira vez, aguarde os containers subirem e rode:

```bash
make db_prepare
make db_seed
```

### Depois da primeira vez

```bash
make start          # Sobe app e banco (logs no terminal)
# ou
make start_background   # Sobe em background
make stop            # Para os containers
```

### Comandos úteis (Makefile)

| Comando | Descrição |
|--------|-----------|
| `make help` | Lista todos os comandos |
| `make setup` | Primeira vez: build + sobe containers + db:prepare + seed |
| `make start` | Sobe app e banco (foreground) |
| `make start_background` | Sobe em background |
| `make stop` | Para os containers |
| `make db_prepare` | Cria/migra o banco |
| `make db_seed` | Roda seeds |
| `make console` | Abre Rails console no container |
| `make logs` | Logs do app em tempo real |

---

## 🏗️ Arquitetura Multi-Tenant

A aplicação usa a gem [acts_as_tenant](https://github.com/ErwinM/acts_as_tenant) para isolamento por tenant (coluna `tenant_id`).

- **Tenant = Cursinho:** cada cursinho é um tenant
- **Acesso por subdomínio:** `objetivo.seudominio.com`, `poliedro.seudominio.com`, etc.
- **Isolamento:** dados filtrados automaticamente pelo tenant atual
- **Banco único:** um PostgreSQL com separação lógica por `tenant_id`

---

### Usuários para Acessar
```
# Senha padrão para todos os usuários de seed (desenvolvimento) é "senha123"

# Usuários por tenant: admin, instrutor e estudantes (email único por tenant no formato tenant_email)
{
  "objetivo" => [
    { email: "super@objetivo.demo", role: :super_admin },
    { email: "admin@objetivo.demo", role: :tenant_admin },
    { email: "instrutor@objetivo.demo", role: :instructor },
    { email: "aluno1@objetivo.demo", role: :student },
    { email: "aluno2@objetivo.demo", role: :student }
  ],
  "poliedro" => [
    { email: "super@poliedro.demo", role: :super_admin }
    { email: "admin@poliedro.demo", role: :tenant_admin },
    { email: "instrutor@poliedro.demo", role: :instructor },
    { email: "aluno1@poliedro.demo", role: :student },
    { email: "aluno2@poliedro.demo", role: :student }
  ],
  "anglo" => [
    { email: "super@anglo.demo", role: :super_admin }
    { email: "admin@anglo.demo", role: :tenant_admin },
    { email: "instrutor@anglo.demo", role: :instructor },
    { email: "aluno1@anglo.demo", role: :student },
    { email: "aluno2@anglo.demo", role: :student }
  ]
}
```


## 📚 Estrutura de Tenants

### Modelo Tenant

```ruby
# app/models/tenant.rb
class Tenant < ApplicationRecord
  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true
end
```

**Campos:** `name`, `subdomain`, `active`

### Adicionando modelos tenantizados

1. Gerar com `tenant_id`:  
   `rails generate model Student name:string email:string tenant:references` (rodar dentro do container, ex.: `make console` ou `docker compose exec app bin/rails g ...`)
2. No modelo: `acts_as_tenant :tenant` e `belongs_to :tenant`
3. Nas migrations: índices compostos com `tenant_id`

---

## 🛠️ Comandos Rails dentro do Docker

Use o container `app`:

```bash
# Console
make console
# ou: docker compose exec app bin/rails console

# Migrations
docker compose exec app bin/rails db:migrate

# Criar tenant (exemplo)
docker compose exec app bin/rails runner "Tenant.create(name: 'Novo Cursinho', subdomain: 'novo')"
```

No console (após `make console`):

```ruby
objetivo = Tenant.find_by(subdomain: 'objetivo')
ActsAsTenant.with_tenant(objetivo) do
  Course.all
  Course.create!(name: "Medicina Intensivo", description: "Preparatório")
end
```

---

## ⚠️ Pontos de atenção

1. Use **`acts_as_tenant :tenant`** em modelos que devem ser isolados por tenant.
2. Migrations: incluir `tenant:references` e índices compostos.
3. Seeds: usar `ActsAsTenant.with_tenant(...)` para criar dados.
4. Testes: configurar um tenant antes de criar dados.

---

## 📡 Documentação da API

Para integração com clientes:
- **Swagger UI**: após subir o servidor, acesse `/api-docs` (ex.: `http://objetivo.lvh.me:3000/api-docs`).

---

## 📦 Stack

- **Rails** 8.1.2
- **PostgreSQL** 17 (container)
- **Ruby** 3.3 (na imagem Docker)

## Problemas que tive
Erro no resolve do namespace db:
comando para resolver: docker network connect --alias db alpha_white_default alpha_white_db
