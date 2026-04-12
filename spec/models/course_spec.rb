require "rails_helper"

RSpec.describe Course, type: :model do
  let(:tenant) { create(:tenant) }
  before { set_tenant(tenant) }

  describe "validações" do
    it { should validate_presence_of(:name) }

    it "rejeita descrição com mais de 1000 caracteres" do
      course = build(:course, tenant: tenant, description: "x" * 1001)
      expect(course).not_to be_valid
      expect(course.errors[:description]).to be_present
    end

    it "aceita descrição com exatamente 1000 caracteres" do
      course = build(:course, tenant: tenant, description: "x" * 1000)
      expect(course).to be_valid
    end

    it "aceita descrição com menos de 1000 caracteres" do
      course = build(:course, tenant: tenant, description: "x" * 100)
      expect(course).to be_valid
    end
  end

  describe "associações" do
    it { should belong_to(:tenant).optional }
    it { should have_many(:sessions).dependent(:destroy) }
  end

  describe "escopos" do
    let!(:ativo)   { create(:course, tenant: tenant, active: true) }
    let!(:inativo) { create(:course, :inactive, tenant: tenant) }

    it ".active retorna apenas cursos ativos" do
      course_ativo = Course.active
      expect(course_ativo).to include(ativo)
      expect(course_ativo).not_to include(inativo)
    end
  end

  describe "multi-tenancy" do
    let(:outro_tenant) { create(:tenant) }

    it "não acessa cursos de outro tenant" do
      create(:course, tenant: tenant)

      ActsAsTenant.with_tenant(outro_tenant) do
        times_create = 3
        times_create.times do
          create(:course, tenant: outro_tenant)
        end
        expect(Course.count).to eq(times_create)
      end

      expect(Course.count).to eq(1)
    end
  end
end
