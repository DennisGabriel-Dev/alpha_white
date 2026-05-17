require "rails_helper"

RSpec.describe "Me::Achievements", type: :request do
  let(:tenant) { create(:tenant) }
  let(:headers) { { "HOST" => "#{tenant.subdomain}.lvh.me" } }

  before { ensure_achievements_catalog! }

  describe "GET /me/conquistas" do
    it "permite aluno" do
      sign_in create(:user, :student, tenant: tenant)
      get me_achievements_path, headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Conquistas")
    end

    it "bloqueia instrutor" do
      sign_in create(:user, :instructor, tenant: tenant)
      get me_achievements_path, headers: headers
      expect(response).to redirect_to(root_path)
    end
  end
end
