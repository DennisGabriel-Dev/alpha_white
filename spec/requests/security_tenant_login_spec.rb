# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Segurança — login cross-tenant", type: :request do
  let(:tenant_a) { create(:tenant, subdomain: "cursinho-a") }
  let(:tenant_b) { create(:tenant, subdomain: "cursinho-b") }
  let!(:user) { create(:user, tenant: tenant_a, email: "aluno@demo.test", password: "password123") }

  it "rejeita login no subdomínio de outro tenant" do
    post user_session_path,
         params: { user: { email: user.email, password: "password123" } },
         headers: { "HOST" => "#{tenant_b.subdomain}.lvh.me" }

    expect(response).to have_http_status(:unprocessable_content)
  end

  it "permite login no subdomínio correto" do
    post user_session_path,
         params: { user: { email: user.email, password: "password123" } },
         headers: { "HOST" => "#{tenant_a.subdomain}.lvh.me" }

    expect(response).to redirect_to(root_path)
  end

  it "desloga sessão se usuário acessa subdomínio errado" do
    sign_in user
    get root_path, headers: { "HOST" => "#{tenant_b.subdomain}.lvh.me" }

    expect(response).to redirect_to(new_user_session_path)
    expect(flash[:alert]).to include("não pertence")
  end
end
