require "rails_helper"

RSpec.describe "Relatórios (autorização)", type: :request do
  let(:tenant) { create(:tenant) }
  let(:headers) { { "HOST" => "#{tenant.subdomain}.lvh.me" } }

  describe "GET /relatorios/aluno" do
    it "permite aluno" do
      sign_in create(:user, :student, tenant: tenant)
      get relatorios_aluno_path, headers: headers
      expect(response).to have_http_status(:ok)
    end

    it "bloqueia instrutor" do
      sign_in create(:user, :instructor, tenant: tenant)
      get relatorios_aluno_path, headers: headers
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /relatorios/turma" do
    it "permite instrutor" do
      sign_in create(:user, :instructor, tenant: tenant)
      get relatorios_turma_path, headers: headers
      expect(response).to have_http_status(:ok)
    end

    it "bloqueia aluno" do
      sign_in create(:user, :student, tenant: tenant)
      get relatorios_turma_path, headers: headers
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /relatorios/escola" do
    it "permite tenant_admin" do
      sign_in create(:user, :tenant_admin, tenant: tenant)
      get relatorios_escola_path, headers: headers
      expect(response).to have_http_status(:ok)
    end

    it "permite super_admin" do
      sign_in create(:user, :super_admin, tenant: tenant)
      get relatorios_escola_path, headers: headers
      expect(response).to have_http_status(:ok)
    end

    it "bloqueia instrutor" do
      sign_in create(:user, :instructor, tenant: tenant)
      get relatorios_escola_path, headers: headers
      expect(response).to redirect_to(root_path)
    end
  end
end
