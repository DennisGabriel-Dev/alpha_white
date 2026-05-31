# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Feature flags do tenant", type: :request do
  let(:tenant) { create(:tenant, feature_flags: { "reports" => false }) }
  let(:student) { create(:user, :student, tenant:) }
  let(:instructor) { create(:user, :instructor, tenant:) }
  let(:headers) { { "HOST" => "#{tenant.subdomain}.lvh.me" } }

  describe "relatórios desligados" do
    it "redireciona aluno ao acessar /relatorios/aluno" do
      sign_in student
      get relatorios_aluno_path, headers: headers

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include("Relatórios")
    end
  end

  describe "csv_export desligado" do
    let(:tenant) { create(:tenant, feature_flags: { "csv_export" => false }) }
    let!(:course) { create(:course, tenant:) }

    it "redireciona instrutor ao exportar CSV" do
      sign_in instructor
      get relatorio_course_path(course), headers: headers

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include("Exportação CSV")
    end
  end

  describe "enem_library desligado" do
    let(:tenant) { create(:tenant, feature_flags: { "enem_library" => false }) }

    it "redireciona instrutor da biblioteca ENEM" do
      sign_in instructor
      get enem_exams_path, headers: headers

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include("Biblioteca ENEM")
    end
  end

  describe "gamification desligado" do
    let(:tenant) { create(:tenant, feature_flags: { "gamification" => false }) }

    it "redireciona aluno de /me/conquistas" do
      sign_in student
      get me_achievements_path, headers: headers

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include("Gamificação")
    end
  end
end
