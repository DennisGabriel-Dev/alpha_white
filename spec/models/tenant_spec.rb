require "rails_helper"

RSpec.describe Tenant, type: :model do
  describe "constantes" do
    it "define os temas disponíveis" do
      expect(Tenant::THEMES).to include("default", "aurora", "merma")
    end
  end

  describe "validações" do
    subject { build(:tenant) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:subdomain) }
    it { should validate_uniqueness_of(:subdomain) }

    it "rejeita subdomínio com espaços" do
      tenant = build(:tenant, subdomain: "meu cursinho")
      expect(tenant).not_to be_valid
      expect(tenant.errors[:subdomain]).to be_present
    end

    it "rejeita subdomínio com letras maiúsculas" do
      tenant = build(:tenant, subdomain: "MeuCursinho")
      expect(tenant).not_to be_valid
    end

    it "aceita subdomínio com letras minúsculas e hífens" do
      tenant = build(:tenant, subdomain: "meu-cursinho")
      expect(tenant).to be_valid
    end

    it "rejeita tema fora da lista permitida" do
      tenant = build(:tenant, theme: "inexistente")
      expect(tenant).not_to be_valid
      expect(tenant.errors[:theme]).to be_present
    end

    it "aceita todos os temas definidos em THEMES" do
      Tenant::THEMES.each do |theme|
        tenant = build(:tenant, theme: theme)
        expect(tenant).to be_valid, "esperado que '#{theme}' fosse válido"
      end
    end
  end

  describe "associações" do
    it { should have_many(:courses).dependent(:destroy) }
    it { should have_many(:users).dependent(:destroy) }
  end

  describe "escopos" do
    let!(:ativo)   { create(:tenant, active: true) }
    let!(:inativo) { create(:tenant, :inactive) }

    it ".active retorna apenas tenants ativos" do
      expect(Tenant.active).to include(ativo)
      expect(Tenant.active).not_to include(inativo)
    end
  end
end
