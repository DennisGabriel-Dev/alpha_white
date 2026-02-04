# Alpha White - Plataforma Whitelabel para Cursinhos Preparatórios

Aplicação Rails 8 com arquitetura **multi-tenant** usando row-level tenancy. Cada cursinho preparatório é um tenant isolado, com seus próprios dados e acesso via subdomínio.

## 🏗️ Arquitetura Multi-Tenant

Esta aplicação utiliza a gem [acts_as_tenant](https://github.com/ErwinM/acts_as_tenant) para implementar isolamento de dados por tenant usando **row-level tenancy** (coluna `tenant_id`).

### Como Funciona

- **Tenant = Cursinho**: Cada cursinho preparatório é um tenant único
- **Acesso por Subdomínio**: `objetivo.seudominio.com`, `poliedro.seudominio.com`, etc.
- **Isolamento Automático**: Todos os dados são automaticamente filtrados pelo tenant atual
- **Banco Único**: Um PostgreSQL com separação lógica por `tenant_id`

## 🚀 Configuração do Projeto

### Pré-requisitos

- Ruby 3.2.1
- PostgreSQL 12+
- Rails 8.1.2

### Instalação

```bash
# Clone o repositório
git clone <repo-url>
cd alpha_white

# Instale as dependências
bundle install

# Configure o banco de dados
rails db:create
rails db:migrate
rails db:seed

# Inicie o servidor
rails server
```

### Acesso Local (Desenvolvimento)

Para testar localmente com subdomínios, você pode:

**Opção 1: Usar lvh.me** (recomendado - funciona sem configuração)
```
http://objetivo.lvh.me:3000
http://poliedro.lvh.me:3000
http://anglo.lvh.me:3000
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

**Campos:**
- `name`: Nome do cursinho (ex: "Cursinho Objetivo")
- `subdomain`: Subdomínio único (ex: "objetivo")
- `active`: Status ativo/inativo

### Adicionando Novos Modelos Tenantizados

Para criar um novo modelo que deve ser isolado por tenant:

**1. Gerar o modelo com tenant_id:**
```bash
rails generate model Student name:string email:string tenant:references
```

**2. Adicionar `acts_as_tenant` no modelo:**
```ruby
class Student < ApplicationRecord
  acts_as_tenant :tenant
  
  belongs_to :tenant
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { scope: :tenant_id }
end
```

**3. Adicionar índices na migration:**
```ruby
add_index :students, [:tenant_id, :id]
add_index :students, [:tenant_id, :email], unique: true
```

**4. Pronto!** O modelo já está isolado por tenant automaticamente.

## 🔒 Como o Isolamento Funciona

### No Controller (Automático)

```ruby
class CoursesController < ApplicationController
  def index
    # Retorna APENAS cursos do tenant atual
    @courses = Course.all
  end
  
  def create
    # O tenant_id é automaticamente definido
    @course = Course.create(course_params)
  end
end
```

### No Console Rails

```ruby
# Buscar tenant
objetivo = Tenant.find_by(subdomain: 'objetivo')

# Trabalhar no contexto de um tenant
ActsAsTenant.with_tenant(objetivo) do
  # Todos os queries aqui são automaticamente filtrados
  Course.all  # Retorna apenas cursos do Objetivo
  Course.create(name: 'Novo Curso')  # Cria com tenant_id = objetivo.id
end

# Fora do contexto, precisa especificar manualmente
Course.where(tenant_id: objetivo.id)
```

## 🛠️ Comandos Úteis

```bash
# Rodar migrations
rails db:migrate

# Popular banco com dados de exemplo
rails db:seed

# Console Rails
rails console

# Criar novo tenant
rails runner "Tenant.create(name: 'Novo Cursinho', subdomain: 'novo')"

# Ver todos os tenants
rails runner "Tenant.all.each { |t| puts '#{t.name}: #{t.subdomain}' }"
```

## 🔍 Exemplo de Uso

### Criando um Tenant

```ruby
tenant = Tenant.create!(
  name: "Cursinho Exemplo",
  subdomain: "exemplo",
  active: true
)
```

### Criando Dados para um Tenant

```ruby
ActsAsTenant.with_tenant(tenant) do
  Course.create!(
    name: "Medicina Intensivo",
    description: "Preparatório para medicina"
  )
end
```

### Listando Dados de um Tenant

```ruby
ActsAsTenant.with_tenant(tenant) do
  puts Course.all.map(&:name)
end
```

## ⚠️ Pontos de Atenção

1. **Sempre use `acts_as_tenant :tenant`** em modelos que devem ser isolados
2. **Foreign keys entre modelos tenantizados** funcionam normalmente
3. **Migrations** devem incluir `tenant:references` e índices compostos
4. **Seeds** devem usar `ActsAsTenant.with_tenant` para criar dados
5. **Testes** devem configurar um tenant antes de criar dados

## 📦 Dependências Principais

- **rails** (~> 8.1.2): Framework
- **pg** (~> 1.1): PostgreSQL
- **acts_as_tenant** (1.0.1): Multi-tenancy
- **tailwindcss-rails**: CSS framework