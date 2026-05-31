# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Segurança — IDOR cross-tenant", type: :request do
  let(:tenant_a) { create(:tenant, subdomain: "cursinho-a") }
  let(:tenant_b) { create(:tenant, subdomain: "cursinho-b") }
  let(:student_a) { create(:user, :student, tenant: tenant_a) }
  let!(:course_b) { create(:course, tenant: tenant_b, name: "Curso secreto B") }

  it "retorna 404 quando aluno do tenant A acessa curso do tenant B pelo ID na URL" do
    sign_in student_a
    get course_path(course_b), headers: { "HOST" => "#{tenant_a.subdomain}.lvh.me" }

    expect(response).to have_http_status(:not_found)
  end
end
