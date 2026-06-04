# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Export CSV do curso", type: :request do
  let(:tenant) { create(:tenant) }
  let(:instructor) { create(:user, :instructor, tenant:) }
  let(:student) { create(:user, :student, tenant:) }
  let!(:course) { create(:course, tenant:) }
  let(:headers) { { "HOST" => "#{tenant.subdomain}.lvh.me" } }

  describe "GET /courses/:id/relatorio" do
    it "permite instrutor e retorna CSV" do
      sign_in instructor
      get relatorio_course_path(course), headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/csv")
      expect(response.headers["Content-Disposition"]).to include("attachment")
      expect(response.body).to include("email")
    end

    it "bloqueia aluno" do
      sign_in student
      get relatorio_course_path(course), headers: headers

      expect(response).to redirect_to(root_path)
    end

    it "aceita filtro de período" do
      sign_in instructor
      get relatorio_course_path(course, from: "2026-01-01", to: "2026-12-31"), headers: headers

      expect(response).to have_http_status(:ok)
    end
  end
end
