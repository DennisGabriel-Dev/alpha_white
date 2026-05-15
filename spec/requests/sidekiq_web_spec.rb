require "rails_helper"

RSpec.describe "Sidekiq Web UI", type: :request do
  let(:tenant) { create(:tenant) }
  let(:headers) { { "HOST" => "#{tenant.subdomain}.lvh.me" } }

  describe "GET /sidekiq" do
    it "redireciona anônimos para o login Devise" do
      get "/sidekiq", headers: headers

      expect(response).to have_http_status(:found)
      expect(response.headers["Location"]).to match(%r{/users/sign_in})
    end

    it "bloqueia estudante com 403" do
      sign_in create(:user, :student, tenant: tenant)
      get "/sidekiq", headers: headers

      expect(response).to have_http_status(:forbidden)
    end

    it "bloqueia tenant_admin com 403" do
      sign_in create(:user, :tenant_admin, tenant: tenant)
      get "/sidekiq", headers: headers

      expect(response).to have_http_status(:forbidden)
    end

    it "bloqueia instrutor com 403" do
      sign_in create(:user, :instructor, tenant: tenant)
      get "/sidekiq", headers: headers

      expect(response).to have_http_status(:forbidden)
    end

    it "permite super_admin" do
      sign_in create(:user, :super_admin, tenant: tenant)
      get "/sidekiq", headers: headers
      follow_redirect! if response.redirect?

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Sidekiq")
    end
  end
end
