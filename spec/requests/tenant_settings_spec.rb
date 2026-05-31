# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Configurações do tenant (brand pack)", type: :request do
  let(:tenant) { create(:tenant, theme: "default", primary_color: "#3C0094") }
  let(:admin) { create(:user, :tenant_admin, tenant:) }
  let(:headers) { { "HOST" => "#{tenant.subdomain}.lvh.me" } }

  describe "PATCH /tenant_setting" do
    it "atualiza tagline e feature flags" do
      sign_in admin
      patch tenant_setting_path, params: {
        tenant: {
          theme: "aurora",
          primary_color: "#1D4ED8",
          tagline: "Novo slogan do cursinho",
          feature_flags: {
            "gamification" => "1",
            "reports" => "1",
            "enem_library" => "0",
            "csv_export" => "0"
          }
        }
      }, headers: headers

      expect(response).to redirect_to(edit_tenant_setting_path)
      tenant.reload
      expect(tenant.tagline).to eq("Novo slogan do cursinho")
      expect(tenant.theme).to eq("aurora")
      expect(tenant.feature_enabled?(:gamification)).to be true
      expect(tenant.feature_enabled?(:enem_library)).to be false
      expect(tenant.feature_enabled?(:csv_export)).to be false
    end

    it "bloqueia instrutor" do
      instructor = create(:user, :instructor, tenant:)
      sign_in instructor
      patch tenant_setting_path, params: { tenant: { tagline: "hack" } }, headers: headers

      expect(response).to redirect_to(root_path)
    end
  end
end
