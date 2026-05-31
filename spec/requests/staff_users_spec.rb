# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Staff users (instrutores)", type: :request do
  let(:tenant) { create(:tenant) }
  let(:admin) { create(:user, :tenant_admin, tenant:) }
  let(:student) { create(:user, :student, tenant:) }
  let(:headers) { { "HOST" => "#{tenant.subdomain}.lvh.me" } }

  describe "GET /equipe" do
    it "permite tenant_admin" do
      sign_in admin
      get staff_users_path, headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Instrutores")
    end

    it "bloqueia aluno" do
      sign_in student
      get staff_users_path, headers: headers
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /equipe" do
    it "cria instrutor no tenant" do
      sign_in admin
      expect do
        post staff_users_path, params: {
          user: {
            email: "prof.novo@example.com",
            password: "senha123",
            password_confirmation: "senha123"
          }
        }, headers: headers
      end.to change { User.instructor.where(tenant: tenant).count }.by(1)

      expect(response).to redirect_to(staff_users_path)
      expect(User.find_by(email: "prof.novo@example.com")).to be_instructor
    end
  end
end
